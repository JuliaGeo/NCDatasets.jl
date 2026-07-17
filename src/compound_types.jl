function usertype!(ds::Dataset,typename,jltype)
    ds.usertypes[Symbol(typename)] = jltype
end

# TODO: reconstruct type if necessary
function usertype(ds::Dataset,typename)
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
    nctype = get(ncType,T,nothing)
    if nctype !== nothing
        return nctype
    end

#   nctype = get(cache,T,nothing)
#   if nctype !== nothing
#       return nctype
#   end

    for (name,userT) in usertypes
        if userT == T
            for id = nc_inq_typeids(ncid)
                if name == Symbol(nc_inq_compound_name(ncid,id))
                    return id
                end
            end
        end
    end

    # make sure that the types of all fields are first created
    # if they are created "on-the-fly" in the second loop, I get
    # julia: nc4hdf.c:397: nc4_get_hdf_typeid: Zusicherung »typeid« nicht erfüllt.

    for i = 1:fieldcount(T)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            @assert all(fT.types .== elT)
            create_compound_type(ncid,elT,string(elT),usertypes)
        else
            create_compound_type(ncid,fT,string(fT),usertypes)
        end
    end

    typeid = nc_def_compound(ncid, sizeof(T), type_name)

    for i = 1:fieldcount(T)
        offset = fieldoffset(T,i)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            nctype = create_compound_type(ncid,elT,string(elT),usertypes)
            dim_sizes = [length(fT.types)]
            nc_insert_array_compound(
                ncid,typeid,fieldname(T,i),
                offset,nctype,dim_sizes)
        else
            nctype = create_compound_type(ncid,fT,string(fT),usertypes)

            nc_insert_compound(
                ncid, typeid, fieldname(T,i),
                offset, nctype)
        end
    end

    usertypes[Symbol(type_name)] = T
    return typeid
end
