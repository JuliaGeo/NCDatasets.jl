function opaque_expr(ncid,typeid)
    typename,len = nc_inq_opaque(ncid,typeid)

    typename = Symbol(typename)
    return :(const $typename = NTuple{$len,UInt8})
end

function reconstruct_opaque_type(ncid,typeid,typemap)
    typename,len = nc_inq_opaque(ncid,typeid)

    if haskey(typemap,Symbol(typename))
        @debug "get cashed type for $typename"
        return typemap[Symbol(typename)]
    end

    return NTuple{Int(len),UInt8}
end


function create_opaque_type(ds,::Type{NTuple{len,UInt8}}; typename = nothing) where len
    ncid = ds.ncid

    typeid = nc_def_opaque(ncid,len,typename)

    @debug "created opaque" typename typeid
    return typeid
end


function _typename(::Type{NTuple{len,UInt8}}) where len
    return "opaque($len)"
end
