# Module for reconstructing user-defined types
# The resulting type is directly captured as it can be overwritten by
# compound type with the same from other files
module ReconstructedTypes end

const ReconstructedTypesLock = ReentrantLock()

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

function reconstruct_compound_type(ncid,xtype,usertypes)
    type_name,type_size,nfields = nc_inq_compound(ncid,xtype)

    # multiple threads could try to reconstruct the same type
    lock(ReconstructedTypesLock) do
        if haskey(usertypes,Symbol(type_name))
            @debug "get cashed type for $type_name"
            return usertypes[Symbol(type_name)]
        end

        cnames = Symbol.(nc_inq_compound_fieldname.(ncid,xtype,0:(nfields-1)))

        types = []
        for fieldid = 0:(nfields-1)
            fT = jlType[nc_inq_compound_fieldtype(ncid,xtype,fieldid)]

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
            ReconstructedTypes,
            Expr(:struct, false, Symbol(type_name),
                 Expr(:block,
                      Any[ Expr(Symbol("::"), cnames[i], types[i]) for i = 1:length(types) ]...,
                      # suppress default constructors, plus a bogus `new()` call to make sure
                      # ninitialized is zero.
                      Expr(:if, false, Expr(:call, :new))
                      )))


        invokelatest() do
            T2 = getfield(ReconstructedTypes, Symbol(type_name))
            usertypes[Symbol(type_name)] = T2
            return T2
        end
    end
end


function create_compound_type(ncid,T,type_name)
    typeid = nc_def_compound(ncid, sizeof(T), type_name)

    for i = 1:fieldcount(T)
        offset = fieldoffset(T,i)
        fT = fieldtype(T,i)
        if fT <: NTuple
            elT = fT.types[1]
            @assert all(fT.types .== elT)
            nctype = ncType[elT]
            dim_sizes = [length(fT.types)]
            nc_insert_array_compound(
                ncid,typeid,fieldname(T,i),
                offset,nctype,dim_sizes)
        else
            nctype = ncType[fieldtype(T,i)]
            nc_insert_compound(
                ncid, typeid, fieldname(T,i),
                offset, nctype)
        end
    end

    return typeid
end
