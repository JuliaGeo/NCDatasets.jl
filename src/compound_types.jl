module NCReconstructedTypes end

function reconstruct_compound_type(ncid,xtype)
    type_name,type_size,nfields = nc_inq_compound(ncid,xtype)

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

        # assume scalars for now
        #@assert nc_inq_compound_fieldndims(ncid,xtype,fieldid) == 0
    end

    # TODO: use different module for scope
    reconname = Symbol(type_name)

    # from JLD2, MIT "Expat" License
    # https://github.com/JuliaIO/JLD2.jl/blob/abb9e5920bbe956a4d9fd2f92550cd7ea0a715aa/src/data/reconstructing_datatypes.jl#L493

    Core.eval(
    NCReconstructedTypes,
    Expr(:struct, false, reconname,
         Expr(:block,
              Any[ Expr(Symbol("::"), cnames[i], types[i]) for i = 1:length(types) ]...,
              # suppress default constructors, plus a bogus `new()` call to make sure
              # ninitialized is zero.
              Expr(:if, false, Expr(:call, :new))
              )))


    invokelatest() do
        T2 = getfield(NCReconstructedTypes, reconname)
#        usertypes[type_name] = NCReconstructedTypes
        return T2
    end
end

