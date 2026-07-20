
nc_inq_enum_name(ncid,typeid) = nc_inq_enum(ncid,typeid)[1]

function reconstruct_enum_type(ncid,xtype,usertypes,mod)
    typename,base_nc_type,base_size,num_members = nc_inq_enum(ncid,xtype)

    if haskey(usertypes,Symbol(typename))
        @debug "get cashed type for $typename"
        return usertypes[Symbol(typename)]
    end

    T = base_nc_type

    members = []
    for idx = 0:num_members-1
        member_name,value = nc_inq_enum_member(ncid,xtype,idx,T)
        push!(members,Symbol(member_name) => value)
    end

    Core.eval(mod,
              Expr(:macrocall,
                   Symbol("@enum"),
                   :(),
                   :($(Symbol(typename))::$T),
                   [:($(Symbol(n)) = $v) for (n,v) in members]... # fixme
                       ))

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

function defEnumType(ds,T,typename)
    nctypeid(ds,T; typename)
end
