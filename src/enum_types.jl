
nc_inq_enum_name(ncid,typeid) = nc_inq_enum(ncid,typeid)[1]

function reconstruct_enum_type(ncid,xtype,usertypes,mod)
    type_name,base_nc_type,base_size,num_members = nc_inq_enum(ncid,xtype)

    if haskey(usertypes,Symbol(type_name))
        @debug "get cashed type for $type_name"
        return usertypes[Symbol(type_name)]
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
                   :($(Symbol(type_name))::$T),
                   [:($(Symbol(n)) = $v) for (n,v) in members]... # fixme
                       ))

    invokelatest() do
        T2 = getfield(mod, Symbol(type_name))
        usertypes[Symbol(type_name)] = T2
        return T2
    end
end


function create_enum_type(ds,T; type_name = nothing)
    ncid = ds.ncid
    members = [Symbol(inst) => Integer(inst) for inst in instances(T)]

    base_type = typeof(first(members)[2])
    base_typeid = ncType[base_type]

    typeid = nc_def_enum(ncid,base_typeid,type_name)

    for (member_name,member_value) in members
        nc_insert_enum(ncid,typeid,member_name,member_value,base_type)
    end

    @debug "created enum" type_name typeid
    return typeid
end

function defEnumType(ds,T,type_name)
    create_type(ds,T; type_name)
end
