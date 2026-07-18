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


function create_enum_type(ncid,T,type_name,usertypes)
    for (name,userT) in usertypes
        if userT == T
            for id = nc_inq_typeids(ncid)
                if name == Symbol(nc_inq_enum_name(ncid,id))
                    return id
                end
            end
        end
    end

    members = [Symbol(inst) => Integer(inst) for inst in instances(T)]

    base_type = typeof(first(members)[2])
    base_typeid = ncType[base_type]

    typeid = nc_def_enum(ncid,base_typeid,type_name)

    for (member_name,member_value) in members
        nc_insert_enum(ncid,typeid,member_name,member_value,base_type)
    end

    usertypes[Symbol(type_name)] = T

    return typeid
end

function defEnumType(ds,T,type_name)
    create_enum_type(ds.ncid,T,type_name,ds.usertypes)
end
