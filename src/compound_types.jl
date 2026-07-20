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


function compound_expr(ncid,typeid,usertypes,mod)
    typename,type_size,nfields = nc_inq_compound(ncid,typeid)

    cnames = Symbol.(nc_inq_compound_fieldname.(ncid,typeid,0:(nfields-1)))

    types = []
    for fieldid = 0:(nfields-1)
        field_typeid = nc_inq_compound_fieldtype(ncid,typeid,fieldid)
        fT = _jltype(ncid,field_typeid,usertypes,mod)

        fieldndims = nc_inq_compound_fieldndims(ncid,typeid,fieldid)

        if fieldndims == 0
            push!(types,fT)
        else
            dim_sizes = nc_inq_compound_fielddim_sizes(ncid,typeid,fieldid)
            fT2 = NTuple{Int(dim_sizes[1]),fT}
            push!(types,fT2)
        end
    end

    # from JLD2, MIT "Expat" License
    # https://github.com/JuliaIO/JLD2.jl/blob/abb9e5920bbe956a4d9fd2f92550cd7ea0a715aa/src/data/reconstructing_datatypes.jl#L493

    @debug "generate type for $typename"

    return Expr(:struct, false, Symbol(typename),
                Expr(:block,
                  Any[ Expr(Symbol("::"), cnames[i], types[i]) for i = 1:length(types) ]...,
                  # suppress default constructors, plus a bogus `new()` call to make sure
                  # ninitialized is zero.
                  Expr(:if, false, Expr(:call, :new))
                     ))
end

function reconstruct_compound_type(ncid,typeid,usertypes,mod)
    typename,type_size,nfields = nc_inq_compound(ncid,typeid)

    if haskey(usertypes,Symbol(typename))
        @debug "get cashed type for $typename"
        return usertypes[Symbol(typename)]
    end

    @debug "generate type for $typename"
    Core.eval(mod,compound_expr(ncid,typeid,usertypes,mod))

    invokelatest() do
        T2 = getfield(mod, Symbol(typename))
        usertypes[Symbol(typename)] = T2
        return T2
    end
end


function create_compound_type(ds,T; typename=nothing)
    ncid = ds.ncid

    # make sure that the types of all fields are first created
    # if they are created "on-the-fly" in the second loop, I get
    # julia: nc4hdf.c:397: nc4_get_hdf_typeid: Zusicherung »typeid« nicht erfüllt.

    for i = 1:fieldcount(T)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            @assert all(fT.types .== elT)
            nctypeid(ds,elT)
        else
            nctypeid(ds,fT)
        end
    end

    typeid = nc_def_compound(ncid, sizeof(T), typename)

    for i = 1:fieldcount(T)
        offset = fieldoffset(T,i)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            nctype = nctypeid(ds,elT)
            dim_sizes = [length(fT.types)]
            nc_insert_array_compound(
                ncid,typeid,fieldname(T,i),
                offset,nctype,dim_sizes)
        else
            nctype = nctypeid(ds,fT)

            nc_insert_compound(
                ncid, typeid, fieldname(T,i),
                offset, nctype)
        end
    end

    @debug "created compound" typename typeid
    return typeid
end

# returns the netCDF typeid and create the type if necessary
function nctypeid(ds,T; typename = nothing)
    ncid = ds.ncid
    usertypes = ds.usertypes

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

                if (class == NC_VLEN) && (T <: AbstractVector)
                    if name == Symbol(first(nc_inq_vlen(ncid,id)))
                        return id
                    end
                elseif class == NC_COMPOUND
                    if name == Symbol(nc_inq_compound_name(ncid,id))
                        return id
                    end
                elseif (class == NC_ENUM) && (T <: Enum)
                    if name == Symbol(first(nc_inq_enum(ncid,id)))
                        return id
                    end
                else
                    # ignore
                end
            end
        end
    end

    if typename == nothing
        typename = last(split(string(T),'.')) # strip module prefix
    end

    if T <: AbstractVector
        eltypeid = nctypeid(ds,eltype(T))
        typeid = nc_def_vlen(ncid, typename, eltypeid)
        @debug "created vlen-array" typename typeid
    elseif T <: Enum
        typeid = create_enum_type(ds,T; typename)
    elseif length(fieldnames(T)) > 0
        @debug "assume type $T is a struct "
        typeid = create_compound_type(ds,T; typename)
    else
        @warn "unsupported type: class=$(class)"
        typeid = Nothing
    end
    usertypes[Symbol(typename)] = T
    return typeid
end


function defType(ds,typename::SymbolOrString,T::DataType)
    nctypeid(ds,T; typename)
    return nothing
end
export defType
