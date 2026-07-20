function enum_expr(ncid,typeid)
    typename,base_nc_type,base_size,num_members = nc_inq_enum(ncid,typeid)

    T = base_nc_type

    members = []
    for idx = 0:num_members-1
        member_name,value = nc_inq_enum_member(ncid,typeid,idx,T)
        push!(members,Symbol(member_name) => value)
    end

    return Expr(:macrocall,
                Symbol("@enum"),
                :(),
                :($(Symbol(typename))::$T),
                [:($n = $v) for (n,v) in members]...
                    )
end

function reconstruct_enum_type(ncid,typeid,usertypes,mod)
    typename, = nc_inq_enum(ncid,typeid)

    if haskey(usertypes,Symbol(typename))
        @debug "get cashed type for $typename"
        return usertypes[Symbol(typename)]
    end

    Core.eval(mod,enum_expr(ncid,typeid))

    invokelatest() do
        T2 = getfield(mod, Symbol(typename))
        usertypes[Symbol(typename)] = T2
        return T2
    end
end


function create_enum_type(ds,T; typename = nothing)
    ncid = ds.ncid
    members = [Symbol(inst) => Integer(inst) for inst in instances(T)]

    base_type = typeof(first(members)[2])
    base_typeid = ncType[base_type]

    typeid = nc_def_enum(ncid,base_typeid,typename)

    for (member_name,member_value) in members
        nc_insert_enum(ncid,typeid,member_name,member_value,base_type)
    end

    @debug "created enum" typename typeid
    return typeid
end
