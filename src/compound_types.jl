"""
    NCDatasets.usertype!(ds::Dataset,typename::SymbolOrString,jltype::DataType)a

Use the julia struct `jltype` for compound types called `typename` defined in then
netCDF dataset `ds`.

Example:

```julia
using NCDatasets
struct MyComplex
    r::Float32
    i::Float32
end

# create some data
n = 10
data = MyComplex.(rand(Float32,n),rand(Float32,n))

fname = tempname()
NCDataset(fname,"c") do ds
    defVar(ds,"data",data,("x",); typename = "nc_complex_t")
end

data = NCDataset(fname) do ds
    # prevent NCDatasets to dynamically reconstruct the struct and use
    # provided type "MyComplex" instead
    NCDatasets.usertype!(ds,"nc_complex_t",MyComplex)
    ds["data"][:]
end

eltype(data)
# output
#
# MyComplex
```
"""
function usertype!(ds::Dataset,typename::SymbolOrString,jltype::DataType)
    ds.usertypes[Symbol(typename)] = jltype
end


# TODO: reconstruct type if necessary
function usertype(ds::Dataset,typename::SymbolOrString)
    ut = get(ds.usertypes,Symbol(typename),nothing)
    if ut == nothing
        pd = parentdataset(ds)
        if pd !== nothing
            return usertype(pd,typename)
        end
    end

    return ut
end

# Module for reconstructing user-defined types
function temp_module()
    modname = Symbol(string("ReconstructedTypes_",rand(UInt32)))
    return eval(:(module $modname end))
end

function reconstruct_compound_type(ncid,xtype,usertypes,mod)
    type_name,type_size,nfields = nc_inq_compound(ncid,xtype)

    if haskey(usertypes,Symbol(type_name))
        @debug "get cashed type for $type_name"
        return usertypes[Symbol(type_name)]
    end

    cnames = Symbol.(nc_inq_compound_fieldname.(ncid,xtype,0:(nfields-1)))

    types = []
    for fieldid = 0:(nfields-1)
        field_typeid = nc_inq_compound_fieldtype(ncid,xtype,fieldid)
        fT = _jltype(ncid,field_typeid,usertypes,mod)

        fieldndims = nc_inq_compound_fieldndims(ncid,xtype,fieldid)

        if fieldndims == 0
            push!(types,fT)
        else
            dim_sizes = nc_inq_compound_fielddim_sizes(ncid,xtype,fieldid)
            fT2 = NTuple{Int(dim_sizes[1]),fT}
            push!(types,fT2)
        end
    end

    # from JLD2, MIT "Expat" License
    # https://github.com/JuliaIO/JLD2.jl/blob/abb9e5920bbe956a4d9fd2f92550cd7ea0a715aa/src/data/reconstructing_datatypes.jl#L493

    @debug "generate type for $type_name"

    Core.eval(
        mod,
        Expr(:struct, false, Symbol(type_name),
             Expr(:block,
                  Any[ Expr(Symbol("::"), cnames[i], types[i]) for i = 1:length(types) ]...,
                  # suppress default constructors, plus a bogus `new()` call to make sure
                  # ninitialized is zero.
                  Expr(:if, false, Expr(:call, :new))
                  )))


    invokelatest() do
        T2 = getfield(mod, Symbol(type_name))
        usertypes[Symbol(type_name)] = T2
        return T2
    end
end


function create_compound_type(ncid,T,type_name,usertypes)

    # make sure that the types of all fields are first created
    # if they are created "on-the-fly" in the second loop, I get
    # julia: nc4hdf.c:397: nc4_get_hdf_typeid: Zusicherung »typeid« nicht erfüllt.

    for i = 1:fieldcount(T)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            @assert all(fT.types .== elT)
            create_type(ncid,elT,string(elT),usertypes)
        else
            create_type(ncid,fT,string(fT),usertypes)
        end
    end

    typeid = nc_def_compound(ncid, sizeof(T), type_name)

    for i = 1:fieldcount(T)
        offset = fieldoffset(T,i)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            nctype = create_type(ncid,elT,string(elT),usertypes)
            dim_sizes = [length(fT.types)]
            nc_insert_array_compound(
                ncid,typeid,fieldname(T,i),
                offset,nctype,dim_sizes)
        else
            nctype = create_type(ncid,fT,string(fT),usertypes)

            nc_insert_compound(
                ncid, typeid, fieldname(T,i),
                offset, nctype)
        end
    end

    @debug "created compound" type_name typeid
    return typeid
end


function create_type(ncid,T,type_name,usertypes)
    # plain type
    nctype = get(ncType,T,nothing)
    if nctype !== nothing
        return nctype
    end

    # check if type is already defined in usertypes
    for (name,userT) in usertypes
        if userT == T
            for id = nc_inq_typeids(ncid)
                _,_,_,_,class = nc_inq_user_type(ncid,id)

                if class == NC_VLEN
                    error("unexpected type")
                elseif class == NC_COMPOUND
                    if name == Symbol(nc_inq_compound_name(ncid,id))
                        return id
                    end
                elseif (class == NC_ENUM) && (T <: Enum)
                    if name == Symbol(nc_inq_enum_name(ncid,id))
                        return id
                    end
                else
                    # ignore
                end
            end
        end
    end

    if T <: Enum
        typeid = create_enum_type(ncid,T,type_name,usertypes)
    else
        typeid = create_compound_type(ncid,T,type_name,usertypes)
    end
    usertypes[Symbol(type_name)] = T
    return typeid
end


function defCompoundType(ds,T,type_name)
    create_type(ds.ncid,T,type_name,ds.usertypes)
end
