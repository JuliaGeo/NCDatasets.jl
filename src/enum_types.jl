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

function reconstruct_enum_type(ncid,typeid,usertypes)
    typename, = nc_inq_enum(ncid,typeid)

    if haskey(usertypes,Symbol(typename))
        @debug "get cashed type for $typename"
        return usertypes[Symbol(typename)]
    end


    typename,base_nc_type,base_size,num_members = nc_inq_enum(ncid,typeid)

    T = base_nc_type

    members = []
    for idx = 0:num_members-1
        member_name,value = nc_inq_enum_member(ncid,typeid,idx,T)
        push!(members,Symbol(member_name) => value)
    end

    names = (first.(members)..., )
    values = (last.(members)..., )
    return NCEnum{Symbol(typename),T,names,values}
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


function enums(v::Variable{ET}) where ET <: NCEnum{typename,T,names,values} where {typename,T,names,values}
    (; (name => ET(value) for (name,value) in zip(names,values))...)
end

function enums(v::Variable{T}) where T <: Enum
    return parentmodule(T)
end


function enums(v::Variable{Union{Missing,T}}) where T <: Enum
    return parentmodule(T)
end


function show(io::IO, x::T) where {T <: NCEnum}
    if get(io, :typeinfo, Any) <: NCEnum
        print(io, x.data)
    else
        Base.show_default(io, x)
    end
end


import Base: Integer, instances, Symbol, instances
Integer(x::NCEnum) = x.data

function instances(::Type{E}) where E <: NCEnum{typename,T,names,values} where {typename,T,names,values}
    [E(v) for v in values]
end

function Symbol(x::NCEnum{typename,T,names,values}) where {typename,T,names,values}
    for (n,v) in zip(names,values)
        if x.data == v
            return n
        end
    end
    error("invalid NCEnum $x")
end


function _typename(::Type{<:NCEnum{typename}}) where {typename}
    typename
end
