# This file is originally based netcdf_c.jl from NetCDF.jl
# Copyright (c) 2012-2013: Fabian Gans, Max-Planck-Institut fuer Biogeochemie, Jena, Germany
# MIT

# Several calls are commented out because they are not captured by tests

const NC_NAT = 0
const NC_BYTE = 1
const NC_CHAR = 2
const NC_SHORT = 3
const NC_INT = 4
const NC_LONG = NC_INT
const NC_FLOAT = 5
const NC_DOUBLE = 6
const NC_UBYTE = 7
const NC_USHORT = 8
const NC_UINT = 9
const NC_INT64 = 10
const NC_UINT64 = 11
const NC_STRING = 12
const NC_MAX_ATOMIC_TYPE = NC_STRING
const NC_VLEN = 13
const NC_OPAQUE = 14
const NC_ENUM = 15
const NC_COMPOUND = 16
const NC_FIRSTUSERTYPEID = 32

const NC_FILL = 0
const NC_NOFILL = 0x0100
const NC_NOWRITE = 0x0000
const NC_WRITE = 0x0001
const NC_CLOBBER = 0x0000
const NC_NOCLOBBER = 0x0004
const NC_DISKLESS = 0x0008
const NC_MMAP = 0x0010
const NC_64BIT_DATA = 0x0020
const NC_CDF5 = NC_64BIT_DATA
const NC_CLASSIC_MODEL = 0x0100
const NC_64BIT_OFFSET = 0x0200
const NC_LOCK = 0x0400
const NC_SHARE = 0x0800
const NC_NETCDF4 = 0x1000
const NC_MPIIO = 0x2000
const NC_MPIPOSIX = 0x4000
const NC_INMEMORY = 0x8000
const NC_PNETCDF = NC_MPIIO
const NC_FORMAT_CLASSIC = 1
const NC_FORMAT_64BIT_OFFSET = 2
const NC_FORMAT_64BIT = NC_FORMAT_64BIT_OFFSET
const NC_FORMAT_NETCDF4 = 3
const NC_FORMAT_NETCDF4_CLASSIC = 4
const NC_FORMAT_64BIT_DATA = 5
const NC_FORMAT_CDF5 = NC_FORMAT_64BIT_DATA
const NC_FORMATX_NC3 = 1
const NC_FORMATX_NC_HDF5 = 2
const NC_FORMATX_NC4 = NC_FORMATX_NC_HDF5
const NC_FORMATX_NC_HDF4 = 3
const NC_FORMATX_PNETCDF = 4
const NC_FORMATX_DAP2 = 5
const NC_FORMATX_DAP4 = 6
const NC_FORMATX_UNDEFINED = 0
const NC_FORMAT_NC3 = NC_FORMATX_NC3
const NC_FORMAT_NC_HDF5 = NC_FORMATX_NC_HDF5
const NC_FORMAT_NC4 = NC_FORMATX_NC4
const NC_FORMAT_NC_HDF4 = NC_FORMATX_NC_HDF4
const NC_FORMAT_PNETCDF = NC_FORMATX_PNETCDF
const NC_FORMAT_DAP2 = NC_FORMATX_DAP2
const NC_FORMAT_DAP4 = NC_FORMATX_DAP4
const NC_FORMAT_UNDEFINED = NC_FORMATX_UNDEFINED
const NC_SIZEHINT_DEFAULT = 0

const NC_UNLIMITED = Cint(0)
const NC_GLOBAL = Cint(-1)
const NC_MAX_DIMS = 1024
const NC_MAX_ATTRS = 8192
const NC_MAX_VARS = 8192
const NC_MAX_NAME = 256
const NC_MAX_VAR_DIMS = 1024
const NC_MAX_HDF4_NAME = 64
const NC_ENDIAN_NATIVE = 0
const NC_ENDIAN_LITTLE = 1
const NC_ENDIAN_BIG = 2
const NC_CHUNKED = 0
const NC_CONTIGUOUS = 1
const NC_NOCHECKSUM = 0
const NC_FLETCHER32 = 1
const NC_NOSHUFFLE = 0
const NC_SHUFFLE = 1

const NC_NOERR = 0
const NC2_ERR = -1
const NC_EBADID = -33
const NC_ENFILE = -34
const NC_EEXIST = -35
const NC_EINVAL = -36
const NC_EPERM = -37
const NC_ENOTINDEFINE = -38
const NC_EINDEFINE = -39
const NC_EINVALCOORDS = -40
const NC_EMAXDIMS = -41
const NC_ENAMEINUSE = -42
const NC_ENOTATT = -43
const NC_EMAXATTS = -44
const NC_EBADTYPE = -45
const NC_EBADDIM = -46
const NC_EUNLIMPOS = -47
const NC_EMAXVARS = -48
const NC_ENOTVAR = -49
const NC_EGLOBAL = -50
const NC_ENOTNC = -51
const NC_ESTS = -52
const NC_EMAXNAME = -53
const NC_EUNLIMIT = -54
const NC_ENORECVARS = -55
const NC_ECHAR = -56
const NC_EEDGE = -57
const NC_ESTRIDE = -58
const NC_EBADNAME = -59
const NC_ERANGE = -60
const NC_ENOMEM = -61
const NC_EVARSIZE = -62
const NC_EDIMSIZE = -63
const NC_ETRUNC = -64
const NC_EAXISTYPE = -65
const NC_EDAP = -66
const NC_ECURL = -67
const NC_EIO = -68
const NC_ENODATA = -69
const NC_EDAPSVC = -70
const NC_EDAS = -71
const NC_EDDS = -72
const NC_EDATADDS = -73
const NC_EDAPURL = -74
const NC_EDAPCONSTRAINT = -75
const NC_ETRANSLATION = -76
const NC_EACCESS = -77
const NC_EAUTH = -78
const NC_ENOTFOUND = -90
const NC_ECANTREMOVE = -91
const NC4_FIRST_ERROR = -100
const NC_EHDFERR = -101
const NC_ECANTREAD = -102
const NC_ECANTWRITE = -103
const NC_ECANTCREATE = -104
const NC_EFILEMETA = -105
const NC_EDIMMETA = -106
const NC_EATTMETA = -107
const NC_EVARMETA = -108
const NC_ENOCOMPOUND = -109
const NC_EATTEXISTS = -110
const NC_ENOTNC4 = -111
const NC_ESTRICTNC3 = -112
const NC_ENOTNC3 = -113
const NC_ENOPAR = -114
const NC_EPARINIT = -115
const NC_EBADGRPID = -116
const NC_EBADTYPID = -117
const NC_ETYPDEFINED = -118
const NC_EBADFIELD = -119
const NC_EBADCLASS = -120
const NC_EMAPTYPE = -121
const NC_ELATEFILL = -122
const NC_ELATEDEF = -123
const NC_EDIMSCALE = -124
const NC_ENOGRP = -125
const NC_ESTORAGE = -126
const NC_EBADCHUNK = -127
const NC_ENOTBUILT = -128
const NC_EDISKLESS = -129
const NC_ECANTEXTEND = -130
const NC_EMPI = -131
const NC4_LAST_ERROR = -131
const DIM_WITHOUT_VARIABLE = "This is a netCDF dimension but not a netCDF variable."
const NC_HAVE_NEW_CHUNKING_API = 1
const NC_EURL = NC_EDAPURL
const NC_ECONSTRAINT = NC_EDAPCONSTRAINT

const NC_INDEPENDENT = 0
const NC_COLLECTIVE = 1
# OpenMPI
const MPI_Comm = Ptr{Cvoid}
const MPI_Info = Ptr{Cvoid}


const NC_ENTOOL = NC_EMAXNAME
const NC_EXDR = -32
const NC_SYSERR = -31
const NC_FATAL = 1

# default fill values

const NC_FILL_BYTE   = Int8(-127)
const NC_FILL_CHAR   = '\0'
const NC_FILL_SHORT  = Int16(-32767)
const NC_FILL_INT    = Int32(-2147483647)
const NC_FILL_FLOAT  = 9.9692099683868690f+36
const NC_FILL_DOUBLE = 9.9692099683868690e+36
const NC_FILL_UBYTE  = UInt8(255)
const NC_FILL_USHORT = UInt16(65535)
const NC_FILL_UINT   = UInt32(4294967295)
const NC_FILL_INT64  = Int64(-9223372036854775806)
const NC_FILL_UINT64 = UInt64(18446744073709551614)
const NC_FILL_STRING = ""

const nc_type = Cint

# global lock to serialize call the NetCDF-c
const NETCDF_LOCK = ReentrantLock()

# type is immutable to ensure that it has the memory same layout
# as the C struct nc_vlen_t

struct nc_vlen_t{T}
    len::Csize_t
    p::Ptr{T}
end

const nclong = Cint

const NCSymbols = Dict{Cint,Symbol}(
    NC_CONTIGUOUS => :contiguous,
    NC_CHUNKED => :chunked
)
# Inverse mapping
const NCConstants = Dict(value => key for (key, value) in NCSymbols)

const NCChecksumSymbols = Dict{Cint,Symbol}(
    NC_FLETCHER32 => :fletcher32,
    NC_NOCHECKSUM => :nochecksum
)
# Inverse mapping
const NCChecksumConstants = Dict(value => key for (key, value) in NCChecksumSymbols)



function convert(::Type{Array{nc_vlen_t{T},N}},data::Array{Vector{T},N}) where {T,N}
    tmp = Array{nc_vlen_t{T},N}(undef,size(data))

    for (i,d) in enumerate(data)
        tmp[i] = nc_vlen_t{T}(length(d), pointer(d))
    end
    return tmp
end


@with_lock function nc_inq_libvers()
    unsafe_string(ccall((:nc_inq_libvers,libnetcdf),Cstring,()))
end

@with_lock function nc_strerror(ncerr::Integer)
    unsafe_string(ccall((:nc_strerror,libnetcdf),Cstring,(Cint,),ncerr))
end

# @with_lock function nc__create(path,cmode::Integer,initialsz::Integer,chunksizehintp,ncidp)
#     check(ccall((:nc__create,libnetcdf),Cint,(Cstring,Cint,Cint,Ptr{Cint},Ptr{Cint}),path,cmode,initialsz,chunksizehintp,ncidp))
# end

@with_lock function nc_create(path,cmode::Integer)
    @debug "nc_create $path with mode $cmode"
    ncidp = Ref(Cint(0))
    check(ccall((:nc_create,libnetcdf),Cint,(Cstring,Cint,Ptr{Cint}),path,cmode,ncidp))
    return ncidp[]
end

# @with_lock function nc__open(path,mode::Integer,chunksizehintp,ncidp)
#     check(ccall((:nc__open,libnetcdf),Cint,(Cstring,Cint,Ptr{Cint},Ptr{Cint}),path,mode,chunksizehintp,ncidp))
# end

@with_lock function nc_open(path,mode::Integer)
    @debug "nc_open $path with mode $mode"
    ncidp = Ref(Cint(0))

    code = ccall((:nc_open,libnetcdf),Cint,(Cstring,Cint,Ptr{Cint}),path,mode,ncidp)

    if code == NC_NOERR
        return ncidp[]
    else
        # otherwise throw an error message
        # with a more helpful error message (i.e. with the path)
        throw(NetCDFError(code, "Opening path $(path): $(nc_strerror_nolock(code))"))
    end
end

@with_lock function nc_open_mem(path,mode::Integer,memory::Vector{UInt8})
    @debug "nc_open $path with mode $mode"
    ncidp = Ref(Cint(0))

    code = ccall(
        (:nc_open_mem,libnetcdf),Cint,
        (Cstring,Cint,Csize_t,Ptr{UInt8},Ptr{Cint}),
        path,mode,length(memory),memory,ncidp)

    if code == NC_NOERR
        return ncidp[]
    else
        # otherwise throw an error message
        # with a more helpful error message (i.e. with the path)
        throw(NetCDFError(code, "Opening path $(path): $(nc_strerror_nolock(code))"))
    end
end

@with_lock function nc_inq_path(ncid::Integer)
    pathlenp = Ref(Csize_t(0))
    check(ccall((:nc_inq_path,libnetcdf),Cint,(Cint,Ptr{Csize_t},Ptr{UInt8}),ncid,pathlenp,C_NULL))

    path = zeros(UInt8,pathlenp[]+1)
    check(ccall((:nc_inq_path,libnetcdf),Cint,(Cint,Ptr{Csize_t},Ptr{UInt8}),ncid,pathlenp,path))

    return unsafe_string(pointer(path))
end

# @with_lock function nc_inq_ncid(ncid::Integer,name,grp_ncid)
#     check(ccall((:nc_inq_ncid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,name,grp_ncid))
# end

@with_lock function nc_inq_grps(ncid::Integer)
    numgrpsp = Ref(Cint(0))
    check(ccall((:nc_inq_grps,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,numgrpsp,C_NULL))
    numgrps = numgrpsp[]

    ncids = Vector{Cint}(undef,numgrps)

    check(ccall((:nc_inq_grps,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,numgrpsp,ncids))

    return ncids
end

@with_lock function nc_inq_grpname(ncid::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)

    check(ccall((:nc_inq_grpname,libnetcdf),Cint,(Cint,Ptr{UInt8}),ncid,name))

    return unsafe_string(pointer(name))
end

# @with_lock function nc_inq_grpname_full(ncid::Integer,lenp,full_name)
#     check(ccall((:nc_inq_grpname_full,libnetcdf),Cint,(Cint,Ptr{Cint},Cstring),ncid,lenp,full_name))
# end

# @with_lock function nc_inq_grpname_len(ncid::Integer,lenp)
#     check(ccall((:nc_inq_grpname_len,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,lenp))
# end

# @with_lock function nc_inq_grp_parent(ncid::Integer,parent_ncid)
#     check(ccall((:nc_inq_grp_parent,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,parent_ncid))
# end

@with_lock function nc_inq_grp_ncid(ncid::Integer,grp_name)
    grp_ncid = Ref(Cint(0))
    check(ccall((:nc_inq_grp_ncid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,grp_name,grp_ncid))
    return grp_ncid[]
end

# @with_lock function nc_inq_grp_full_ncid(ncid::Integer,full_name,grp_ncid)
#     check(ccall((:nc_inq_grp_full_ncid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,full_name,grp_ncid))
# end

@with_lock function nc_inq_varids(ncid::Integer)::Vector{Cint}
    # first get number of variables
    nvarsp = Ref(Cint(0))
    check(ccall((:nc_inq_varids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nvarsp,C_NULL))
    nvars = nvarsp[]

    varids = zeros(Cint,nvars)
    check(ccall((:nc_inq_varids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nvarsp,varids))
    return varids
end

@with_lock function nc_inq_dimids(ncid::Integer,include_parents::Bool)
    ndimsp = Ref(Cint(0))
    ndims = nc_inq_ndims_nolock(ncid)
    dimids = Vector{Cint}(undef,ndims)
    check(ccall((:nc_inq_dimids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint},Cint),ncid,ndimsp,dimids,include_parents))

    return dimids
end

@with_lock function nc_inq_typeids(ncid::Integer)
    ntypesp = Ref(Cint(0))
    check(ccall((:nc_inq_typeids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,ntypesp,C_NULL))

    typeids = Vector{Cint}(undef,ntypesp[])
    check(ccall((:nc_inq_typeids,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,C_NULL,typeids))

    return typeids
end

# @with_lock function nc_inq_type_equal(ncid1::Integer,typeid1::Integer,ncid2::Integer,typeid2::Integer,equal)
#     check(ccall((:nc_inq_type_equal,libnetcdf),Cint,(Cint,nc_type,Cint,nc_type,Ptr{Cint}),ncid1,typeid1,ncid2,typeid2,equal))
# end

#"""
#Create a group with the name `name` returnings its id.
#"""
@with_lock function nc_def_grp(parent_ncid::Integer,name)
    new_ncid = Ref(Cint(0))
    check(ccall((:nc_def_grp,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),parent_ncid,name,new_ncid))

    return new_ncid[]
end

# @with_lock function nc_rename_grp(grpid::Integer,name)
#     check(ccall((:nc_rename_grp,libnetcdf),Cint,(Cint,Cstring),grpid,name))
# end

@with_lock function nc_def_compound(ncid::Integer,size::Integer,name)
    typeidp = Ref{nc_type}()
    check(ccall((:nc_def_compound,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{nc_type}),ncid,size,name,typeidp))
    return typeidp[]
end

@with_lock function nc_insert_compound(ncid::Integer,xtype::Integer,name,offset::Integer,field_typeid::Integer)
    check(ccall((:nc_insert_compound,libnetcdf),Cint,(Cint,nc_type,Cstring,Csize_t,nc_type),ncid,xtype,name,offset,field_typeid))
end

@with_lock function nc_insert_array_compound(ncid::Integer,xtype::Integer,name,offset::Integer,field_typeid::Integer,dim_sizes)
    ndims = length(dim_sizes)
    check(ccall((:nc_insert_array_compound,libnetcdf),Cint,(Cint,nc_type,Cstring,Cint,nc_type,Cint,Ptr{Cint}),ncid,xtype,name,offset,field_typeid,ndims,dim_sizes))
end

# @with_lock function nc_inq_type(ncid::Integer,xtype::Integer,name,size)
#     check(ccall((:nc_inq_type,libnetcdf),Cint,(Cint,nc_type,Cstring,Ptr{Cint}),ncid,xtype,name,size))
# end

# @with_lock function nc_inq_typeid(ncid::Integer,name,typeidp)
#     check(ccall((:nc_inq_typeid,libnetcdf),Cint,(Cint,Cstring,Ptr{nc_type}),ncid,name,typeidp))
# end

@with_lock function nc_inq_compound(ncid::Integer,xtype::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    sizep = Ref{Csize_t}()
    nfieldsp = Ref{Csize_t}()

    check(ccall((:nc_inq_compound,libnetcdf),Cint,(Cint,nc_type,Ptr{UInt8},Ptr{Csize_t},Ptr{Csize_t}),ncid,xtype,name,sizep,nfieldsp))

    return unsafe_string(pointer(name)), sizep[], nfieldsp[]
end

@with_lock function nc_inq_compound_name(ncid::Integer,xtype::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    check(ccall((:nc_inq_compound_name,libnetcdf),Cint,(Cint,nc_type,Ptr{UInt8}),ncid,xtype,name))
    return unsafe_string(pointer(name))
end

@with_lock function nc_inq_compound_size(ncid::Integer,xtype::Integer)
    sizep = Ref{Csize_t}()
    check(ccall((:nc_inq_compound_size,libnetcdf),Cint,(Cint,nc_type,Ptr{Csize_t}),ncid,xtype,sizep))
    return sizep[]
end

@with_lock function nc_inq_compound_nfields(ncid::Integer,xtype::Integer)
    nfieldsp = Ref{Csize_t}()
    check(ccall((:nc_inq_compound_nfields,libnetcdf),Cint,(Cint,nc_type,Ptr{Csize_t}),ncid,xtype,nfieldsp))
    return nfieldsp[]
end

# @with_lock function nc_inq_compound_field(ncid::Integer,xtype::Integer,fieldid::Integer,name,offsetp,field_typeidp,ndimsp,dim_sizesp)
#     check(ccall((:nc_inq_compound_field,libnetcdf),Cint,(Cint,nc_type,Cint,Cstring,Ptr{Cint},Ptr{nc_type},Ptr{Cint},Ptr{Cint}),ncid,xtype,fieldid,name,offsetp,field_typeidp,ndimsp,dim_sizesp))
# end

@with_lock function nc_inq_compound_fieldname(ncid::Integer,xtype::Integer,fieldid::Integer)
    name = zeros(UInt8,NC_MAX_NAME+1)
    check(ccall((:nc_inq_compound_fieldname,libnetcdf),Cint,(Cint,nc_type,Cint,Ptr{UInt8}),ncid,xtype,fieldid,name))
    return unsafe_string(pointer(name))
end

@with_lock function nc_inq_compound_fieldindex(ncid::Integer,xtype::Integer,name)
    fieldidp = Ref{Cint}()
    check(ccall((:nc_inq_compound_fieldindex,libnetcdf),Cint,(Cint,nc_type,Cstring,Ptr{Cint}),ncid,xtype,name,fieldidp))
    return fieldidp[]
end

@with_lock function nc_inq_compound_fieldoffset(ncid::Integer,xtype::Integer,fieldid::Integer)
    offsetp = Ref{Cint}()
    check(ccall((:nc_inq_compound_fieldoffset,libnetcdf),Cint,(Cint,nc_type,Cint,Ptr{Cint}),ncid,xtype,fieldid,offsetp))
    return offsetp[]
end

@with_lock function nc_inq_compound_fieldtype(ncid::Integer,xtype::Integer,fieldid::Integer)
    field_typeidp = Ref{nc_type}()
    check(ccall((:nc_inq_compound_fieldtype,libnetcdf),Cint,(Cint,nc_type,Cint,Ptr{nc_type}),ncid,xtype,fieldid,field_typeidp))
    return field_typeidp[]
end

@with_lock function nc_inq_compound_fieldndims(ncid::Integer,xtype::Integer,fieldid::Integer)
    ndimsp = Ref{Cint}()
    check(ccall((:nc_inq_compound_fieldndims,libnetcdf),Cint,(Cint,nc_type,Cint,Ptr{Cint}),ncid,xtype,fieldid,ndimsp))
    return ndimsp[]
end

@with_lock function nc_inq_compound_fielddim_sizes(ncid::Integer,xtype::Integer,fieldid::Integer)
    ndims = nc_inq_compound_fieldndims_nolock(ncid,xtype,fieldid)
    dim_sizes = zeros(Cint,ndims)
    check(ccall((:nc_inq_compound_fielddim_sizes,libnetcdf),Cint,(Cint,nc_type,Cint,Ptr{Cint}),ncid,xtype,fieldid,dim_sizes))
    return dim_sizes
end

@with_lock function nc_def_vlen(ncid::Integer,name,base_typeid::Integer)
    xtypep = Ref(nc_type(0))

    check(ccall((:nc_def_vlen,libnetcdf),Cint,(Cint,Cstring,nc_type,Ptr{nc_type}),ncid,name,base_typeid,xtypep))

    return xtypep[]
end

@with_lock function nc_inq_vlen(ncid::Integer,xtype::Integer)
    # datum_size is sizeof(nc_vlen_t)
    datum_sizep = Ref(Csize_t(0))
    base_nc_typep = Ref(nc_type(0))
    name = zeros(UInt8,NC_MAX_NAME+1)

    check(ccall((:nc_inq_vlen,libnetcdf),Cint,(Cint,nc_type,Ptr{UInt8},Ptr{Csize_t},Ptr{nc_type}),ncid,xtype,name,datum_sizep,base_nc_typep))

    return unsafe_string(pointer(name)),datum_sizep[],base_nc_typep[]
end

@with_lock function nc_free_vlen(vl::nc_vlen_t{T}) where {T}
    check(ccall((:nc_free_vlen,libnetcdf),Cint,(Ptr{nc_vlen_t{T}},),Ref(vl)))
end

# @with_lock function nc_free_vlens(len::Integer,vlens)
#     check(ccall((:nc_free_vlens,libnetcdf),Cint,(Cint,Ptr{nc_vlen_t}),len,vlens))
# end

# @with_lock function nc_put_vlen_element(ncid::Integer,typeid1::Integer,vlen_element,len::Integer,data)
#     check(ccall((:nc_put_vlen_element,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing},Cint,Ptr{Nothing}),ncid,typeid1,vlen_element,len,data))
# end

# @with_lock function nc_get_vlen_element(ncid::Integer,typeid1::Integer,vlen_element,len,data)
#     check(ccall((:nc_get_vlen_element,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing},Ptr{Cint},Ptr{Nothing}),ncid,typeid1,vlen_element,len,data))
# end

# @with_lock function nc_free_string(len::Integer,data)
#     check(ccall((:nc_free_string,libnetcdf),Cint,(Cint,Ptr{Ptr{UInt8}}),len,data))
# end


#"""
#    name,size,base_nc_type,nfields,class = nc_inq_user_type(ncid::Integer,xtype::Integer)
#"""
@with_lock function nc_inq_user_type(ncid::Integer,xtype::Integer)
    name = Vector{UInt8}(undef,NC_MAX_NAME+1)
    sizep = Ref(Csize_t(0))
    base_nc_typep = Ref(nc_type(0))
    nfieldsp = Ref(Csize_t(0))
    classp = Ref(Cint(0))

    check(ccall((:nc_inq_user_type,libnetcdf),Cint,(Cint,nc_type,Ptr{UInt8},Ptr{Csize_t},Ptr{nc_type},Ptr{Csize_t},Ptr{Cint}),ncid,xtype,name,sizep,base_nc_typep,nfieldsp,classp))

    return unsafe_string(pointer(name)),sizep[],base_nc_typep[],nfieldsp[],classp[]
end

@with_lock function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,typeid::Integer,data::Vector)
    check(ccall((:nc_put_att,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Csize_t,Ptr{Nothing}),
                ncid,varid,name,typeid,length(data),data))
end

@with_lock function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::AbstractString)
    if Symbol(name) == :_FillValue
        nc_put_att_string_nolock(ncid,varid,"_FillValue",[data])
    else
        check(ccall((:nc_put_att_text,libnetcdf),Cint,(Cint,Cint,Cstring,Csize_t,Cstring),
                    ncid,varid,name,sizeof(data),data))
    end
end

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Vector{Char})
    nc_put_att(ncid,varid,name,join(data))
end

# NetCDF does not necessarily support 64 bit integer attributes
function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Int64)
    if Symbol(name) == :_FillValue
        nc_put_att(ncid,varid,name,ncType[Int64],[data])
    else
        nc_put_att(ncid,varid,name,Int32(data))
    end
end

nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Vector{Int64}) =
    nc_put_att(ncid,varid,name,Int32.(data))

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Number)
    nc_put_att(ncid,varid,name,ncType[typeof(data)],[data])
end

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Char)
    # UInt8('α')
    # ERROR: InexactError: trunc(UInt8, 945)
    nc_put_att(ncid,varid,name,ncType[typeof(data)],[UInt8(data)])
end

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Vector{T}) where T <: AbstractString
    nc_put_att(ncid,varid,name,ncType[String],pointer.(data))
end

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Vector{T}) where {T}
    nc_put_att(ncid,varid,name,ncType[T],data)
end

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::Vector{Any})
    T = promote_type(typeof.(data)...)
    @debug "promoted type for attribute $T"
    nc_put_att(ncid,varid,name,ncType[T],T.(data))
end

# convert e.g. ranges to vectors
function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data::AbstractVector)
    nc_put_att(ncid,varid,name,Vector(data))
end

function nc_put_att(ncid::Integer,varid::Integer,name::SymbolOrString,data)
    error("attributes can only be scalars or vectors")
end


@with_lock function nc_get_att(ncid::Integer,varid::Integer,name)
    xtype,len = nc_inq_att_nolock(ncid,varid,name)

    if xtype == NC_CHAR
        val = Vector{UInt8}(undef,len)
        check(ccall((:nc_get_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Nothing}),ncid,varid,name,val))

        # Note
        # fillvalues for character attributes must be returns as Char and not a strings
        if name == "_FillValue"
            return Char(val[1])
        end

        if any(val .== 0)
            # consider the null terminating character if present
            # see issue #12
            return unsafe_string(pointer(val))
        else
            return unsafe_string(pointer(val),length(val))
        end
    elseif xtype == NC_STRING
        val = Vector{Ptr{UInt8}}(undef,len)
        check(ccall((:nc_get_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Nothing}),ncid,varid,name,val))

        str = unsafe_string.(val)
        if len == 1
            return str[1]
        else
            return str
        end
    else
        val = Vector{jlType[xtype]}(undef,len)
        check(ccall((:nc_get_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Nothing}),ncid,varid,name,val))

        if len == 1
            return val[1]
        else
            return val
        end
    end
end

# Enum

@with_lock function nc_def_enum(ncid::Integer,base_typeid::Integer,name)
    typeidp = Ref(NCDatasets.nc_type(0))
    check(ccall((:nc_def_enum,libnetcdf),Cint,(Cint,nc_type,Cstring,Ptr{nc_type}),ncid,base_typeid,name,typeidp))

    return typeidp[]
end

@with_lock function nc_inq_enum(ncid::Integer,xtype::Integer)

    base_nc_typep = Ref(nc_type(0))
    base_sizep = Ref(Csize_t(0))
    num_membersp = Ref(Csize_t(0))
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check(ccall((:nc_inq_enum,libnetcdf),Cint,(Cint,nc_type,Ptr{UInt8},Ptr{NCDatasets.nc_type},Ptr{Csize_t},Ptr{Csize_t}),ncid,xtype,cname,base_nc_typep,base_sizep,num_membersp))

    type_name = unsafe_string(pointer(cname))
    base_nc_type = base_nc_typep[]
    num_members = num_membersp[]
    base_size = base_sizep[]

    return type_name,jlType[base_nc_type],base_size,num_members
end


@with_lock function nc_insert_enum(ncid::Integer,xtype::Integer,name,value,
                        T = nc_inq_enum_nolock(ncid,typeid)[2])
    valuep = Ref{T}(value)
    check(ccall((:nc_insert_enum,libnetcdf),Cint,(Cint,nc_type,Cstring,Ptr{Nothing}),ncid,xtype,name,valuep))
end

@with_lock function nc_inq_enum_member(ncid::Integer,xtype::Integer,idx::Integer,
                            T::Type = nc_inq_enum_nolock(ncid,typeid)[2])
    valuep = Ref{T}()
    cmember_name = zeros(UInt8,NCDatasets.NC_MAX_NAME+1)

    check(ccall((:nc_inq_enum_member,libnetcdf),Cint,(Cint,nc_type,Cint,Ptr{UInt8},Ptr{Nothing}),ncid,xtype,idx,cmember_name,valuep))

    member_name = unsafe_string(pointer(cmember_name))

    return member_name,valuep[]
end

@with_lock function nc_inq_enum_ident(ncid::Integer,xtype::Integer,value)
    cidentifier = zeros(UInt8,NCDatasets.NC_MAX_NAME+1)
    check(ccall((:nc_inq_enum_ident,libnetcdf),Cint,(Cint,nc_type,Clonglong,Ptr{UInt8}),ncid,xtype,Clonglong(value),cidentifier))
    identifier = unsafe_string(pointer(cidentifier))
    return identifier
end

# @with_lock function nc_def_opaque(ncid::Integer,size::Integer,name,xtypep)
#     check(ccall((:nc_def_opaque,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{nc_type}),ncid,size,name,xtypep))
# end

# @with_lock function nc_inq_opaque(ncid::Integer,xtype::Integer,name,sizep)
#     check(ccall((:nc_inq_opaque,libnetcdf),Cint,(Cint,nc_type,Cstring,Ptr{Cint}),ncid,xtype,name,sizep))
# end

# can the NetCDF variable varid receive the data?
function _nc_shape_check(ncid,varid,data,start,count,stride)
    @debug ncid,varid,data,start,count,stride
end

function nc_put_var(ncid::Integer,varid::Integer,data::Array{Char,N}) where N
    nc_put_var(ncid,varid,convert(Array{UInt8,N},data))
end

function nc_put_var(ncid::Integer,varid::Integer,data::Array{String,N}) where N
    # pointer.(data) is surprisingly a scalar pointer Ptr{UInt8} if data is a
    # Array{T,0}
    tmp = map(pointer,data)
    nc_put_var(ncid,varid,tmp)
end

function nc_put_var(ncid::Integer,varid::Integer,data::Array{Vector{T},N}) where {T,N}
    nc_put_var(ncid,varid,convert(Array{nc_vlen_t{T},N},data))
end

@with_lock function nc_unsafe_put_var(ncid::Integer,varid::Integer,data::Array)
    check(ccall((:nc_put_var,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing}),ncid,varid,data))
end

# data can be a range that must first be converted to an array
@with_lock function nc_unsafe_put_var(ncid::Integer,varid::Integer,data)
    check(ccall((:nc_put_var,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing}),ncid,varid,Array(data)))
end

function nc_put_var(ncid::Integer,varid::Integer,data)
    dimids = nc_inq_vardimid(ncid,varid)
    ndims = length(dimids)
    ncsize = ntuple(i -> nc_inq_dimlen(ncid,dimids[ndims-i+1]), ndims)

    if isempty(nc_inq_unlimdims(ncid))
        if ncsize != size(data)
            path = nc_inq_path(ncid)
            varname = nc_inq_varname(ncid,varid)
            throw(NetCDFError(-1,"wrong size of variable '$varname' (size $ncsize) in file '$path' for an array of size $(size(data))"))
        end

        nc_unsafe_put_var(ncid,varid,data)
    else
        # honor this good advice:

        # Take care when using this function with record variables (variables
        # that use the ::NC_UNLIMITED dimension). If you try to write all the
        # values of a record variable into a netCDF file that has no record data
        # yet (hence has 0 records), nothing will be written. Similarly, if you
        # try to write all the values of a record variable but there are more
        # records in the file than you assume, more in-memory data will be
        # accessed than you supply, which may result in a segmentation
        # violation. To avoid such problems, it is better to use the nc_put_vara
        # interfaces for variables that use the ::NC_UNLIMITED dimension.

        # https://github.com/Unidata/netcdf-c/blob/48cc56ea3833df455337c37186fa6cd7fac9dc7e/libdispatch/dvarput.c#L895

        startp = zeros(ndims)
        countp = Int[reverse(size(data))...,]
        nc_put_vara(ncid,varid,startp,countp,data)
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip::Array{Char,N}) where N
    tmp = Array{UInt8,N}(undef,size(ip))
    nc_get_var!(ncid,varid,tmp)
    for i in eachindex(tmp)
        ip[i] = Char(tmp[i])
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip::Array{String,N}) where N
    tmp = Array{Ptr{UInt8},N}(undef,size(ip))
    nc_get_var!(ncid,varid,tmp)
    for i in eachindex(tmp)
        #ip[:] = unsafe_string.(tmp)
        ip[i] = unsafe_string(tmp[i])
    end
end

function nc_get_var!(ncid::Integer,varid::Integer,ip::Array{Vector{T},N}) where {T,N}
    tmp = Array{NCDatasets.nc_vlen_t{T},N}(undef,size(ip))
    nc_get_var!(ncid,varid,tmp)

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T},tmp[i].p,(tmp[i].len,))
    end
end

@with_lock function nc_get_var!(ncid::Integer,varid::Integer,ip)
    check(ccall((:nc_get_var,libnetcdf),Cint,(Cint,Cint,Ptr{Nothing}),ncid,varid,ip))
end

@with_lock function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::Vector{T}) where T
    tmp = nc_vlen_t{T}(length(op), pointer(op))
    check(ccall((:nc_put_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,Ref(tmp)))
end

@with_lock function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::T) where T
    @debug "nc_put_var1",indexp,op
    check(ccall((:nc_put_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,T[op]))
end

@with_lock function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::Char)
   @debug "nc_put_var1 char",indexp,op
   check(ccall((:nc_put_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,[UInt8(op)]))
end

@with_lock function nc_put_var1(ncid::Integer,varid::Integer,indexp,op::String)
   @debug "nc_put_var1 String",indexp,op
   check(ccall((:nc_put_var1_string,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Cstring}),ncid,varid,indexp,[op]))
end

@with_lock function nc_get_var1(::Type{Char},ncid::Integer,varid::Integer,indexp)
    @debug "nc_get_var1",indexp
    tmp = Ref(UInt8(0))
    check(ccall((:nc_get_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,tmp))
    return Char(tmp[])
end

@with_lock function nc_get_var1(::Type{String},ncid::Integer,varid::Integer,indexp)
    tmp = Ref(Ptr{UInt8}(0))
    check(ccall((:nc_get_var1_string,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Ptr{UInt8}}),ncid,varid,indexp,tmp))
    return unsafe_string(tmp[])
end

@with_lock function nc_get_var1(::Type{T},ncid::Integer,varid::Integer,indexp) where T
    @debug "nc_get_var1" indexp
    ip = Ref{T}()
    check(ccall((:nc_get_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,ip))
    return ip[]
end

@with_lock function nc_get_var1(::Type{Vector{T}},ncid::Integer,varid::Integer,indexp) where T
    ip = Ref(nc_vlen_t{T}(zero(T),Ptr{T}()))
    check(ccall((:nc_get_var1,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Nothing}),ncid,varid,indexp,ip))
    #data = unsafe_wrap(Vector{T},ip[].p,(ip[].len,))
    data = copy(unsafe_wrap(Vector{T},ip[].p,(ip[].len,)))
    nc_free_vlen(ip[])
    return data
end

@with_lock function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,op)
    check(ccall((:nc_put_vara,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Nothing}),ncid,varid,startp,countp,op))
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,op::Array{Char,N}) where N
    tmp = convert(Array{UInt8,N},op)
    nc_put_vara(ncid,varid,startp,countp,tmp)
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,op::Array{String,N}) where N
    nc_put_vara(ncid,varid,startp,countp,pointer.(op))
end

function nc_put_vara(ncid::Integer,varid::Integer,startp,countp,
                     op::Array{Vector{T},N}) where {T,N}

    nc_put_vara(ncid,varid,startp,countp,
                convert(Array{nc_vlen_t{T},N},op))
end

@with_lock function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip)
    @debug "nc_get_vara!",startp,countp
    check(ccall((:nc_get_vara,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Nothing}),ncid,varid,startp,countp,ip))
end

function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{Char,N}) where N
    tmp = Array{UInt8,N}(undef,size(ip))
    nc_get_vara!(ncid,varid,startp,countp,tmp)
    for i in eachindex(tmp)
        ip[i] = Char(tmp[i])
    end
end

function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{String,N}) where N
    tmp = Array{Ptr{UInt8},N}(undef,size(ip))
    nc_get_vara!(ncid,varid,startp,countp,tmp)
    for i in eachindex(tmp)
        #ip[:] = unsafe_string.(tmp)
        ip[i] = unsafe_string(tmp[i])
    end
end


function nc_get_vara!(ncid::Integer,varid::Integer,startp,countp,ip::Array{Vector{T},N}) where {T,N}
    tmp = Array{NCDatasets.nc_vlen_t{T},N}(undef,size(ip))
    nc_get_vara!(ncid,varid,startp,countp,tmp)

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T},tmp[i].p,(tmp[i].len,))
    end
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,
                     op::Array{Char,N}) where N
    tmp = Array{UInt8,N}(undef,size(op))
    for i in eachindex(op)
        tmp[i] = UInt8(op[i])
    end

    nc_put_vars(ncid,varid,startp,countp,stridep,tmp)
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,
                     op::Array{String,N}) where N
    nc_put_vars(ncid,varid,startp,countp,stridep,pointer.(op))
end

function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,
                     op::Array{Vector{T},N}) where {T,N}

    nc_put_vars(ncid,varid,startp,countp,stridep,
                convert(Array{nc_vlen_t{T},N},op))
end

function _nc_check_size_put_vars(ncid,varid,countp,op)
    # dimension index for NetCDF variable
    i1 = 1
    # dimension index of data op
    i2 = 1

    # not_one(x) = x != 1
    # if filter(not_one,reverse(countp)) != filter(not_one,[size(op)...])
    #     path = nc_inq_path(ncid)
    #     varname = nc_inq_varname(ncid,varid)
    #     throw(DimensionMismatch("size mismatch for variable '$(varname)' in file '$(path)'. Trying to write $(size(op)) elements while $(countp) are expected"))
    # end

    unlimdims = nc_inq_unlimdims(ncid)
    dimids = nc_inq_vardimid(ncid,varid)

    countp = reverse(countp)
    dimids = reverse(dimids)

    while true
        if (i2 > ndims(op)) && (i1 > length(countp))
            break
        end

        count_i1 =
            if i1 <= length(countp)
                countp[i1]
            else
                1
            end

        # ignore dimensions with only one element
        if (count_i1 == 1) && (i1 <= length(countp))
            i1 += 1
            continue
        end
        if size(op,i2) == 1 && (i2 <= ndims(op))
            i2 += 1
            continue
        end

        # no test for unlimited dimensions
        if (i1 <= length(dimids)) && (dimids[i1] in unlimdims)
            # ok
        elseif (size(op,i2) !== count_i1)
            path = nc_inq_path(ncid)
            varname = nc_inq_varname(ncid,varid)

            throw(NetCDFError(NC_EEDGE,"size mismatch for variable '$(varname)' in file '$(path)'. Trying to write $(size(op)) elements while $(countp) are expected"))
        end

        i1 += 1
        i2 += 1
    end
end

@with_lock function nc_put_vars(ncid::Integer,varid::Integer,startp,countp,stridep,op)
    @debug "nc_put_vars: $startp,$countp,$stridep"
    @debug "shape $(size(op))"
    _nc_check_size_put_vars(ncid,varid,countp,op)

    check(ccall((:nc_put_vars,libnetcdf),Cint,
                (Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},
                 Ptr{Cint},Ptr{Nothing}),ncid,varid,startp,countp,stridep,op))
end


function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip::Array{Char,N}) where N
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    tmp = Array{UInt8,N}(undef,size(ip))
    nc_get_vars!(ncid,varid,startp,countp,stridep,tmp)
    for i in eachindex(tmp)
        ip[i] = Char(tmp[i])
    end
    @debug "end nc_get_vars!"
end

function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip::Array{String,N}) where N
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    tmp = Array{Ptr{UInt8},N}(undef,size(ip))
    nc_get_vars!(ncid,varid,startp,countp,stridep,tmp)
    for i in eachindex(tmp)
        #ip[:] = unsafe_string.(tmp)
        ip[i] = unsafe_string(tmp[i])
    end
end

function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip::Array{Vector{T},N}) where {T,N}
    @debug "nc_get_vars!: $startp,$countp,$stridep"
    tmp = Array{NCDatasets.nc_vlen_t{T},N}(undef,size(ip))
    nc_get_vars!(ncid,varid,startp,countp,stridep,tmp)

    for i in eachindex(tmp)
        ip[i] = unsafe_wrap(Vector{T},tmp[i].p,(tmp[i].len,))
    end
end

@with_lock function nc_get_vars!(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
    @debug "nc_get_vars!: $startp,$countp,$stridep"

    if any(<(0),stridep)
        reverse_dim = stridep .< 0
        strider = copy(stridep)
        startr = copy(startp)

        for i = 1:length(stridep)
            if reverse_dim[i]
                strider[i] = -stridep[i]
                startr[i] = startp[i] + (countp[i]-1)*stridep[i]
            end
        end

        check(ccall((:nc_get_vars,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Cint},Ptr{Nothing}),ncid,varid,startr,countp,strider,ip))

        # reverse(reverse_dim) is necessary because stride uses the C ordering
        reverse!(ip,dims=Tuple(findall(reverse(reverse_dim))))
    else
        check(ccall((:nc_get_vars,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t},Ptr{Csize_t},Ptr{Cint},Ptr{Nothing}),ncid,varid,startp,countp,stridep,ip))
    end
end


# @with_lock function nc_put_varm(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Nothing}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Nothing}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

@with_lock function nc_def_var_deflate(ncid::Integer,varid::Integer,shuffle::Bool,deflate::Integer,deflate_level::Integer)
    ishuffle = (shuffle ? 1 : 0)
    check(ccall((:nc_def_var_deflate,libnetcdf),Cint,(Cint,Cint,Cint,Cint,Cint),ncid,varid,shuffle,deflate,deflate_level))
end

# filters
@with_lock function nc_inq_filter_avail(ncid::Integer,id::Integer)
    ret = ccall((:nc_inq_filter_avail,libnetcdf),Cint,(Cint,Cuint),ncid,id)
    return ret == NC_NOERR
end

@with_lock function nc_def_var_zstandard(ncid::Integer,varid::Integer,level::Integer)
    check(ccall((:nc_def_var_zstandard,libnetcdf),Cint,(Cint,Cint,Cint),ncid,varid,level))
end

@with_lock function nc_inq_var_zstandard(ncid::Integer,varid::Integer)
    hasfilterp = Ref(Cint(0))
    levelp = Ref(Cint(0))
    check(ccall((:nc_inq_var_zstandard,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint}),ncid,varid,hasfilterp,levelp))

    return hasfilterp[] == 1, levelp[]
end

@with_lock function nc_inq_var_deflate(ncid::Integer,varid::Integer)
    shufflep = Ref(Cint(0))
    deflatep = Ref(Cint(0))
    deflate_levelp = Ref(Cint(0))

    ncerr = ccall((:nc_inq_var_deflate,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,shufflep,deflatep,deflate_levelp)

    if ncerr == NC_ENOTNC4
       # work-around for netcdf 4.7.4
       # https://github.com/Unidata/netcdf-c/issues/1691
       return false, false, Cint(0)
    else
       check(ncerr)
       return shufflep[] == 1, deflatep[] == 1, deflate_levelp[]
    end

end

# @with_lock function nc_inq_var_szip(ncid::Integer,varid::Integer,options_maskp,pixels_per_blockp)
#     check(ccall((:nc_inq_var_szip,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint}),ncid,varid,options_maskp,pixels_per_blockp))
# end

@with_lock function nc_def_var_fletcher32(ncid::Integer,varid::Integer,fletcher32)
    check(ccall((:nc_def_var_fletcher32,libnetcdf),Cint,(Cint,Cint,Cint),ncid,varid,NCChecksumConstants[fletcher32]))
end

@with_lock function nc_inq_var_fletcher32(ncid::Integer,varid::Integer)
    fletcher32p = Ref(Cint(0))
    check(ccall((:nc_inq_var_fletcher32,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,fletcher32p))
    return NCChecksumSymbols[fletcher32p[]]
end

@with_lock function nc_def_var_chunking(ncid::Integer,varid::Integer,storage,chunksizes)
    check(ccall((:nc_def_var_chunking,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Csize_t}),ncid,varid,NCConstants[storage],collect(chunksizes)))
end

@with_lock function nc_inq_var_chunking(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims(ncid,varid)
    storagep = Ref(Cint(0))
    chunksizes = zeros(Csize_t,ndims)

    check(ccall((:nc_inq_var_chunking,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Csize_t}),ncid,varid,storagep,chunksizes))

    return NCSymbols[storagep[]],Tuple(Int.(chunksizes))
end


#"""
#no_fill is a boolean and fill_value the value
#"""
@with_lock function nc_def_var_fill(ncid::Integer,varid::Integer,no_fill::Bool,fill_value)
    check(ccall((:nc_def_var_fill,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Nothing}),
                ncid,
                varid,
                Cint(no_fill),
                [fill_value]))
end

@with_lock function nc_def_var_fill(ncid::Integer,varid::Integer,no_fill::Bool,fill_value::String)
    check(ccall((:nc_def_var_fill,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{Nothing}),
                ncid,
                varid,
                Cint(no_fill),
                [pointer(fill_value)]))
end

#"""
#no_fill,fill_value = nc_inq_var_fill(ncid::Integer,varid::Integer)
#no_fill is a boolean and fill_value the fill value (in the appropriate type)
#"""
@with_lock function nc_inq_var_fill(ncid::Integer,varid::Integer)
    T = jlType[nc_inq_vartype_nolock(ncid,varid)]
    no_fillp = Ref(Cint(0))

    if T == String
        fill_valuep = Vector{Ptr{UInt8}}(undef,1)
        #fill_valuep = Ptr{UInt8}()
        check(ccall((:nc_inq_var_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),unsafe_string(fill_valuep[1])
    elseif T == Char
        fill_valuep = Ref(UInt8(0))
        check(ccall((:nc_inq_var_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),Char(fill_valuep[])
    else
        fill_valuep = Ref{T}()
        check(ccall((:nc_inq_var_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Nothing}),
                ncid,varid,no_fillp,fill_valuep))
        return Bool(no_fillp[]),fill_valuep[]
    end
end

# @with_lock function nc_def_var_endian(ncid::Integer,varid::Integer,endian::Integer)
#     check(ccall((:nc_def_var_endian,libnetcdf),Cint,(Cint,Cint,Cint),ncid,varid,endian))
# end

# @with_lock function nc_inq_var_endian(ncid::Integer,varid::Integer,endianp)
#     check(ccall((:nc_inq_var_endian,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,endianp))
# end

# @with_lock function nc_set_fill(ncid::Integer,fillmode::Integer,old_modep)
#     check(ccall((:nc_set_fill,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,fillmode,old_modep))
# end

# @with_lock function nc_set_default_format(format::Integer,old_formatp)
#     check(ccall((:nc_set_default_format,libnetcdf),Cint,(Cint,Ptr{Cint}),format,old_formatp))
# end

# """
#     nc_set_chunk_cache(size::Integer,nelems::Integer,preemption::Number)

# Sets the default chunk cache settins.

# See netcdf C library documentation for `nc_set_chunk_cache` for details.

# https://www.unidata.ucar.edu/software/netcdf/workshops/most-recent/nc4chunking/Cache.html
# """
@with_lock function nc_set_chunk_cache(size::Integer,nelems::Integer,preemption::Number)
    check(ccall((:nc_set_chunk_cache,libnetcdf),Cint,(Csize_t,Csize_t,Cfloat),size,nelems,preemption))
end

@with_lock function nc_get_chunk_cache()
    sizep = Ref{Csize_t}()
    nelemsp = Ref{Csize_t}()
    preemptionp = Ref{Cfloat}()
    check(ccall((:nc_get_chunk_cache,libnetcdf),Cint,(Ptr{Csize_t},Ptr{Csize_t},Ptr{Cfloat}),sizep,nelemsp,preemptionp))
    return Int(sizep[]),Int(nelemsp[]),preemptionp[]
end

# @with_lock function nc_set_var_chunk_cache(ncid::Integer,varid::Integer,size::Integer,nelems::Integer,preemption::Cfloat)
#     check(ccall((:nc_set_var_chunk_cache,libnetcdf),Cint,(Cint,Cint,Cint,Cint,Cfloat),ncid,varid,size,nelems,preemption))
# end

# @with_lock function nc_get_var_chunk_cache(ncid::Integer,varid::Integer,sizep,nelemsp,preemptionp)
#     check(ccall((:nc_get_var_chunk_cache,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,sizep,nelemsp,preemptionp))
# end

@with_lock function nc_redef(ncid::Integer)
    check(ccall((:nc_redef,libnetcdf),Cint,(Cint,),ncid))
end

# @with_lock function nc__enddef(ncid::Integer,h_minfree::Integer,v_align::Integer,v_minfree::Integer,r_align::Integer)
#     check(ccall((:nc__enddef,libnetcdf),Cint,(Cint,Cint,Cint,Cint,Cint),ncid,h_minfree,v_align,v_minfree,r_align))
# end

@with_lock function nc_enddef(ncid::Integer)
    check(ccall((:nc_enddef,libnetcdf),Cint,(Cint,),ncid))
end

@with_lock function nc_sync(ncid::Integer)
    check(ccall((:nc_sync,libnetcdf),Cint,(Cint,),ncid))
end

# @with_lock function nc_abort(ncid::Integer)
#     check(ccall((:nc_abort,libnetcdf),Cint,(Cint,),ncid))
# end

@with_lock function nc_close(ncid::Integer)
    @debug("closing $ncid")
    check(ccall((:nc_close,libnetcdf),Cint,(Cint,),ncid))
    @debug("end close $ncid")
end

# @with_lock function nc_inq(ncid::Integer,ndimsp,nvarsp,nattsp,unlimdimidp)
#     check(ccall((:nc_inq,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,ndimsp,nvarsp,nattsp,unlimdimidp))
# end

@with_lock function nc_inq_ndims(ncid::Integer)
    ndimsp = Ref(Cint(0))
    check(ccall((:nc_inq_ndims,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,ndimsp))
    return ndimsp[]
end

# @with_lock function nc_inq_nvars(ncid::Integer,nvarsp)
#     check(ccall((:nc_inq_nvars,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,nvarsp))
# end

# @with_lock function nc_inq_natts(ncid::Integer,nattsp)
#     check(ccall((:nc_inq_natts,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,nattsp))
# end

# @with_lock function nc_inq_unlimdim(ncid::Integer,unlimdimidp)
#     check(ccall((:nc_inq_unlimdim,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,unlimdimidp))
# end

# """
# Returns the identifiers of unlimited dimensions
# """
@with_lock function nc_inq_unlimdims(ncid::Integer)
    nunlimdimsp = Ref(Cint(0))
    check(ccall((:nc_inq_unlimdims,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nunlimdimsp,C_NULL))

    unlimdimids = Vector{Cint}(undef,nunlimdimsp[])
    check(ccall((:nc_inq_unlimdims,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nunlimdimsp,unlimdimids))
    return unlimdimids
end

@with_lock function nc_inq_format(ncid::Integer)
    formatp = Ref(Cint(0))
    check(ccall((:nc_inq_format,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,formatp))
    return formatp[]
end

@with_lock function nc_inq_format_extended(ncid::Integer)
    formatp = Ref(Cint(0))
    modep = Ref(Cint(0))

    check(ccall((:nc_inq_format_extended,libnetcdf),Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,formatp,modep))

    return formatp[], modep[]
end

# """
# Define the dimension with the name NAME and the length LEN in the
# dataset NCID. The id of the dimension is returned.
# """
@with_lock function nc_def_dim(ncid::Integer,name,len::Integer)
    idp = Ref(Cint(0))

    check(ccall((:nc_def_dim,libnetcdf),Cint,(Cint,Cstring,Cint,Ptr{Cint}),ncid,name,len,idp))
    return idp[]
end

# """Return the id of a NetCDF dimension."""
@with_lock function nc_inq_dimid(ncid::Integer,name)
    dimidp = Ref(Cint(0))
    check(ccall((:nc_inq_dimid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,name,dimidp))
    return dimidp[]
end

# @with_lock function nc_inq_dim(ncid::Integer,dimid::Integer,name,lenp)
#     check(ccall((:nc_inq_dim,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cint}),ncid,dimid,name,lenp))
# end

@with_lock function nc_inq_dimname(ncid::Integer,dimid::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check(ccall((:nc_inq_dimname,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,dimid,cname))

    return unsafe_string(pointer(cname))
end

@with_lock function nc_inq_dimlen(ncid::Integer,dimid::Integer)
    lengthp = Ref(Csize_t(0))
    check(ccall((:nc_inq_dimlen,libnetcdf),Cint,(Cint,Cint,Ptr{Csize_t}),ncid,dimid,lengthp))
    return Int(lengthp[])
end

@with_lock function nc_rename_dim(ncid::Integer,dimid::Integer,name)
    check(ccall((:nc_rename_dim,libnetcdf),Cint,(Cint,Cint,Cstring),ncid,dimid,name))
end

# check presence of attribute without raising an error
@with_lock function _nc_has_att(ncid::Integer,varid::Integer,name)
    xtypep = Ref(nc_type(0))
    lenp = Ref(Csize_t(0))
    code = ccall((:nc_inq_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{nc_type},Ptr{Csize_t}),ncid,varid,name,xtypep,lenp)
    return code == NC_NOERR
end


@with_lock function nc_inq_att(ncid::Integer,varid::Integer,name)
    xtypep = Ref(nc_type(0))
    lenp = Ref(Csize_t(0))

    check(ccall((:nc_inq_att,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{nc_type},Ptr{Csize_t}),ncid,varid,name,xtypep,lenp))

    return xtypep[],lenp[]
end

# @with_lock function nc_inq_attid(ncid::Integer,varid::Integer,name,idp)
#     check(ccall((:nc_inq_attid,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cint}),ncid,varid,name,idp))
# end

# @with_lock function nc_inq_atttype(ncid::Integer,varid::Integer,name,xtypep)
#     check(ccall((:nc_inq_atttype,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{nc_type}),ncid,varid,name,xtypep))
# end

# @with_lock function nc_inq_attlen(ncid::Integer,varid::Integer,name,lenp)
#     check(ccall((:nc_inq_attlen,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cint}),ncid,varid,name,lenp))
# end

@with_lock function nc_inq_attname(ncid::Integer,varid::Integer,attnum::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1)

    check(ccall((:nc_inq_attname,libnetcdf),Cint,(Cint,Cint,Cint,Ptr{UInt8}),ncid,varid,attnum,cname))
    # really necessary?
    cname[end]=0

   return unsafe_string(pointer(cname))
end

# @with_lock function nc_copy_att(ncid_in::Integer,varid_in::Integer,name,ncid_out::Integer,varid_out::Integer)
#     check(ccall((:nc_copy_att,libnetcdf),Cint,(Cint,Cint,Cstring,Cint,Cint),ncid_in,varid_in,name,ncid_out,varid_out))
# end

# @with_lock function nc_rename_att(ncid::Integer,varid::Integer,name,newname)
#     check(ccall((:nc_rename_att,libnetcdf),Cint,(Cint,Cint,Cstring,Cstring),ncid,varid,name,newname))
# end

@with_lock function nc_del_att(ncid::Integer,varid::Integer,name)
     check(ccall((:nc_del_att,libnetcdf),Cint,(Cint,Cint,Cstring),ncid,varid,name))
end

# @with_lock function nc_put_att_text(ncid::Integer,varid::Integer,name,len::Integer,op)
#     check(ccall((:nc_put_att_text,libnetcdf),Cint,(Cint,Cint,Cstring,Cint,Cstring),ncid,varid,name,len,op))
# end

# @with_lock function nc_get_att_text(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_text,libnetcdf),Cint,(Cint,Cint,Cstring,Cstring),ncid,varid,name,ip))
# end

@with_lock function nc_put_att_string(ncid::Integer,varid::Integer,name,data)
    len = length(data)
    op = pointer(pointer.(data))

    check(ccall((:nc_put_att_string,libnetcdf),Cint,(Cint,Cint,Cstring,Cint,Ptr{Cstring}),ncid,varid,name,len,op))
end

# @with_lock function nc_get_att_string(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_string,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Ptr{UInt8}}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_uchar(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_uchar,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Cuchar}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_uchar(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_uchar,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cuchar}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_schar(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_schar,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{UInt8}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_schar(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_schar,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{UInt8}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_short(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_short,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Int16}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_short(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_short,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Int16}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_int(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_int,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Cint}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_int(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_int,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cint}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_long(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_long,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Clong}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_long(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_long,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Clong}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_float(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_float,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Cfloat}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_float(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_float,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cfloat}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_double(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_double,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Cdouble}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_double(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_double,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Cdouble}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_ushort(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_ushort,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{UInt16}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_ushort(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_ushort,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{UInt16}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_uint(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_uint,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{UInt32}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_uint(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_uint,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{UInt32}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_longlong(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_longlong,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Clonglong}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_longlong(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_longlong,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Clonglong}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_att_ulonglong(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_ulonglong,libnetcdf),Cint,(Cint,Cint,Cstring,nc_type,Cint,Ptr{Culonglong}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_ulonglong(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_ulonglong,libnetcdf),Cint,(Cint,Cint,Cstring,Ptr{Culonglong}),ncid,varid,name,ip))
# end

@with_lock function nc_def_var(ncid::Integer,name,xtype::Integer,dimids::Vector{Cint})
    varidp = Ref(Cint(0))

    check(ccall((:nc_def_var,libnetcdf),Cint,(Cint,Cstring,nc_type,Cint,Ptr{Cint},Ptr{Cint}),ncid,name,xtype,length(dimids),dimids,varidp))

    return varidp[]
end

# get matching julia type
function _jltype(ncid,xtype)
    jltype =
        if xtype >= NCDatasets.NC_FIRSTUSERTYPEID
            name,size,base_nc_type,nfields,class = nc_inq_user_type(ncid,xtype)
            # assume here variable-length type
            if class == NC_VLEN
                Vector{jlType[base_nc_type]}
            else
                @warn "unsupported type: class=$(class)"
                Nothing
            end
        else
            jlType[xtype]
        end

    return jltype
end


@with_lock function nc_inq_var(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims_nolock(ncid,varid)

    ndimsp = Ref(Cint(0))
    cname = zeros(UInt8,NC_MAX_NAME+1)
    dimids = zeros(Cint,ndims)
    nattsp = Ref(Cint(0))
    xtypep = Ref(nc_type(0))

    check(ccall((:nc_inq_var,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8},Ptr{nc_type},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,cname,xtypep,ndimsp,dimids,nattsp))

    name = unsafe_string(pointer(cname))

    xtype = xtypep[]
    jltype = _jltype(ncid,xtype)

    return name,jltype,dimids,nattsp[]
end

@with_lock function nc_inq_varid(ncid::Integer,name)
    varidp = Ref(Cint(0))

    code = ccall((:nc_inq_varid,libnetcdf),Cint,(Cint,Cstring,Ptr{Cint}),ncid,name,varidp);
    if code == NC_NOERR
        return varidp[]
    else
        # return a more helpful error message (i.e. with the path)
        path =
            try
                nc_inq_path(ncid)
            catch
                "<unknown>"
            end

        throw(NetCDFError(code, "Variable '$name' not found in file $path"))
    end
end

@with_lock function nc_inq_varname(ncid::Integer,varid::Integer)
    cname = zeros(UInt8,NC_MAX_NAME+1)
    check(ccall((:nc_inq_varname,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,varid,cname))
    return unsafe_string(pointer(cname))
end

@with_lock function nc_inq_vartype(ncid::Integer,varid::Integer)
    xtypep = Ref(nc_type(0))
    check(ccall((:nc_inq_vartype,libnetcdf),Cint,(Cint,Cint,Ptr{nc_type}),ncid,varid,xtypep))
    return xtypep[]
end

@with_lock function nc_inq_varndims(ncid::Integer,varid::Integer)
    ndimsp = Ref(Cint(0))
    check(ccall((:nc_inq_varndims,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,ndimsp))
    return ndimsp[]
end

@with_lock function nc_inq_vardimid(ncid::Integer,varid::Integer)
    ndims = nc_inq_varndims_nolock(ncid,varid)
    dimids = zeros(Cint,ndims)
    check(ccall((:nc_inq_vardimid,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,dimids))
    return dimids
end

@with_lock function nc_inq_varnatts(ncid::Integer,varid::Integer)
    nattsp = Ref(Cint(0))

    check(ccall((:nc_inq_varnatts,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,nattsp))

    return nattsp[]
end

@with_lock function nc_rename_var(ncid::Integer,varid::Integer,name)
    check(ccall((:nc_rename_var,libnetcdf),Cint,(Cint,Cint,Cstring),ncid,varid,name))
end

# @with_lock function nc_copy_var(ncid_in::Integer,varid::Integer,ncid_out::Integer)
#     check(ccall((:nc_copy_var,libnetcdf),Cint,(Cint,Cint,Cint),ncid_in,varid,ncid_out))
# end

# @with_lock function nc_put_var1_text(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt8}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_text(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt8}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_uchar(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cuchar}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_uchar(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cuchar}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_schar(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt8}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_schar(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt8}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_short(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Int16}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_short(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Int16}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_int(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_int(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_long(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Clong}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_long(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Clong}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_float(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cfloat}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_float(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cfloat}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_double(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cdouble}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_double(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cdouble}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_ushort(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt16}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_ushort(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt16}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_uint(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt32}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_uint(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{UInt32}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_longlong(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Clonglong}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_longlong(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Clonglong}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_ulonglong(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Culonglong}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_ulonglong(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Culonglong}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_var1_string(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_string(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_vara_text(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_text(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_uchar(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_uchar(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_schar(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_schar(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_short(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Int16}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_short(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Int16}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_int(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_int(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_long(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Clong}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_long(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Clong}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_float(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_float(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_double(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cdouble}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_double(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cdouble}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_ushort(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt16}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_ushort(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt16}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_uint(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt32}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_uint(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{UInt32}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_longlong(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Clonglong}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_longlong(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Clonglong}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_ulonglong(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Culonglong}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_ulonglong(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Culonglong}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vara_string(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_string(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vars_text(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_text(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_uchar(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_uchar(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_schar(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_schar(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_short(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Int16}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_short(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Int16}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_int(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_int(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_long(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clong}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_long(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clong}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_float(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_float(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_double(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cdouble}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_double(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cdouble}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_ushort(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt16}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_ushort(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt16}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_uint(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt32}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_uint(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt32}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_longlong(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clonglong}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_longlong(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clonglong}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_ulonglong(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Culonglong}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_ulonglong(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Culonglong}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_vars_string(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_string(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_varm_text(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_text(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_text,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_uchar(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_uchar(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_schar(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_schar(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_schar,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt8}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_short(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Int16}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_short(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_short,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Int16}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_int(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_int(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_long(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clong}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_long(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_long,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clong}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_float(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_float(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cfloat}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_double(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cdouble}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_double(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cdouble}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_ushort(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt16}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_ushort(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt16}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_uint(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt32}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_uint(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_uint,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{UInt32}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_longlong(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clonglong}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_longlong(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Clonglong}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_ulonglong(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Culonglong}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_ulonglong(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Culonglong}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_varm_string(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_string(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_string,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Ptr{UInt8}}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_var_text(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_text,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,varid,op))
# end

# @with_lock function nc_get_var_text(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_text,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_uchar(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cuchar}),ncid,varid,op))
# end

# @with_lock function nc_get_var_uchar(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_uchar,libnetcdf),Cint,(Cint,Cint,Ptr{Cuchar}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_schar(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_schar,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,varid,op))
# end

# @with_lock function nc_get_var_schar(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_schar,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_short(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_short,libnetcdf),Cint,(Cint,Cint,Ptr{Int16}),ncid,varid,op))
# end

# @with_lock function nc_get_var_short(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_short,libnetcdf),Cint,(Cint,Cint,Ptr{Int16}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_int(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,op))
# end

# @with_lock function nc_get_var_int(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_int,libnetcdf),Cint,(Cint,Cint,Ptr{Cint}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_long(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_long,libnetcdf),Cint,(Cint,Cint,Ptr{Clong}),ncid,varid,op))
# end

# @with_lock function nc_get_var_long(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_long,libnetcdf),Cint,(Cint,Cint,Ptr{Clong}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_float(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cfloat}),ncid,varid,op))
# end

# @with_lock function nc_get_var_float(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_float,libnetcdf),Cint,(Cint,Cint,Ptr{Cfloat}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_double(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cdouble}),ncid,varid,op))
# end

# @with_lock function nc_get_var_double(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_double,libnetcdf),Cint,(Cint,Cint,Ptr{Cdouble}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_ushort(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{UInt16}),ncid,varid,op))
# end

# @with_lock function nc_get_var_ushort(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_ushort,libnetcdf),Cint,(Cint,Cint,Ptr{UInt16}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_uint(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_uint,libnetcdf),Cint,(Cint,Cint,Ptr{UInt32}),ncid,varid,op))
# end

# @with_lock function nc_get_var_uint(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_uint,libnetcdf),Cint,(Cint,Cint,Ptr{UInt32}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_longlong(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Clonglong}),ncid,varid,op))
# end

# @with_lock function nc_get_var_longlong(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_longlong,libnetcdf),Cint,(Cint,Cint,Ptr{Clonglong}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_ulonglong(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Culonglong}),ncid,varid,op))
# end

# @with_lock function nc_get_var_ulonglong(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_ulonglong,libnetcdf),Cint,(Cint,Cint,Ptr{Culonglong}),ncid,varid,ip))
# end

# @with_lock function nc_put_var_string(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_string,libnetcdf),Cint,(Cint,Cint,Ptr{Ptr{UInt8}}),ncid,varid,op))
# end

# @with_lock function nc_get_var_string(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_string,libnetcdf),Cint,(Cint,Cint,Ptr{Ptr{UInt8}}),ncid,varid,ip))
# end

# @with_lock function nc_put_att_ubyte(ncid::Integer,varid::Integer,name,xtype::Integer,len::Integer,op)
#     check(ccall((:nc_put_att_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8},nc_type,Cint,Ptr{Cuchar}),ncid,varid,name,xtype,len,op))
# end

# @with_lock function nc_get_att_ubyte(ncid::Integer,varid::Integer,name,ip)
#     check(ccall((:nc_get_att_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{UInt8},Ptr{Cuchar}),ncid,varid,name,ip))
# end

# @with_lock function nc_put_var1_ubyte(ncid::Integer,varid::Integer,indexp,op)
#     check(ccall((:nc_put_var1_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cuchar}),ncid,varid,indexp,op))
# end

# @with_lock function nc_get_var1_ubyte(ncid::Integer,varid::Integer,indexp,ip)
#     check(ccall((:nc_get_var1_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cuchar}),ncid,varid,indexp,ip))
# end

# @with_lock function nc_put_vara_ubyte(ncid::Integer,varid::Integer,startp,countp,op)
#     check(ccall((:nc_put_vara_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,op))
# end

# @with_lock function nc_get_vara_ubyte(ncid::Integer,varid::Integer,startp,countp,ip)
#     check(ccall((:nc_get_vara_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,ip))
# end

# @with_lock function nc_put_vars_ubyte(ncid::Integer,varid::Integer,startp,countp,stridep,op)
#     check(ccall((:nc_put_vars_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,op))
# end

# @with_lock function nc_get_vars_ubyte(ncid::Integer,varid::Integer,startp,countp,stridep,ip)
#     check(ccall((:nc_get_vars_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,ip))
# end

# @with_lock function nc_put_varm_ubyte(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,op)
#     check(ccall((:nc_put_varm_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,imapp,op))
# end

# @with_lock function nc_get_varm_ubyte(ncid::Integer,varid::Integer,startp,countp,stridep,imapp,ip)
#     check(ccall((:nc_get_varm_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cint},Ptr{Cuchar}),ncid,varid,startp,countp,stridep,imapp,ip))
# end

# @with_lock function nc_put_var_ubyte(ncid::Integer,varid::Integer,op)
#     check(ccall((:nc_put_var_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cuchar}),ncid,varid,op))
# end

# @with_lock function nc_get_var_ubyte(ncid::Integer,varid::Integer,ip)
#     check(ccall((:nc_get_var_ubyte,libnetcdf),Cint,(Cint,Cint,Ptr{Cuchar}),ncid,varid,ip))
# end

# @with_lock function nc_show_metadata(ncid::Integer)
#     check(ccall((:nc_show_metadata,libnetcdf),Cint,(Cint,),ncid))
# end

# @with_lock function nc__create_mp(path,cmode::Integer,initialsz::Integer,basepe::Integer,chunksizehintp,ncidp)
#     check(ccall((:nc__create_mp,libnetcdf),Cint,(Cstring,Cint,Cint,Cint,Ptr{Cint},Ptr{Cint}),path,cmode,initialsz,basepe,chunksizehintp,ncidp))
# end

# @with_lock function nc__open_mp(path,mode::Integer,basepe::Integer,chunksizehintp,ncidp)
#     check(ccall((:nc__open_mp,libnetcdf),Cint,(Cstring,Cint,Cint,Ptr{Cint},Ptr{Cint}),path,mode,basepe,chunksizehintp,ncidp))
# end

# @with_lock function nc_delete(path)
#     check(ccall((:nc_delete,libnetcdf),Cint,(Cstring,),path))
# end

# @with_lock function nc_delete_mp(path,basepe::Integer)
#     check(ccall((:nc_delete_mp,libnetcdf),Cint,(Cstring,Cint),path,basepe))
# end

# @with_lock function nc_set_base_pe(ncid::Integer,pe::Integer)
#     check(ccall((:nc_set_base_pe,libnetcdf),Cint,(Cint,Cint),ncid,pe))
# end

# @with_lock function nc_inq_base_pe(ncid::Integer,pe)
#     check(ccall((:nc_inq_base_pe,libnetcdf),Cint,(Cint,Ptr{Cint}),ncid,pe))
# end

@with_lock function nc_rc_set(key,value)
    #nc_rc_set(const char* key, const char* value);
    check(ccall((:nc_rc_set,libnetcdf),Cint,(Cstring,Cstring),key,value))
end

@with_lock function nc_rc_get(key)
    p = ccall((:nc_rc_get,libnetcdf),Cstring,(Cstring,),key)

    if p != C_NULL
        unsafe_string(p)
    else
        error("NetCDF: nc_rc_get: unable to get key $key")
    end
end

function netcdf_version()
    VersionNumber(split(nc_inq_libvers())[1])
end

@with_lock function init_certificate_authority()
    value = ca_roots()
    if value == nothing
        return
    end

    key = "HTTP.SSL.CAINFO"
    hostport = C_NULL
    path = C_NULL

    if netcdf_version() <= v"4.9.0"
        err = @ccall(libnetcdf.NCDISPATCH_initialize()::Cint)
        err = @ccall(libnetcdf.NC_rcfile_insert(key::Cstring, value::Cstring, hostport::Cstring, path::Cstring)::Cint)
        @debug "NC_rcfile_insert returns $err"

        if err != NC_NOERR
            @warn "setting HTTP.SSL.CAINFO using NC_rcfile_insert " *
                "failed with error $err. See https://github.com/JuliaGeo/NCDatasets.jl/issues/173 for more information. "

            @debug begin
                lookup = @ccall(libnetcdf.NC_rclookup(key::Cstring, hostport::Cstring, path::Cstring)::Cstring)

                if lookup !== C_NULL
                    @debug "NC_rclookup: ",unsafe_string(lookup)
                else
                    @debug "NC_rclookup result pointer: ",lookup
                end
            end
        end
    else
        @debug "nc_rc_set: set $key to $value"
        nc_rc_set_nolock(key,value)
    end
end
