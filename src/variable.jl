#=
Functionality and definitions
related with the `Variables` types/subtypes
=#



############################################################
# Helper functions (internal)
############################################################
"Return all variable names"
listVar(ncid) = String[nc_inq_varname(ncid,varid)
                       for varid in nc_inq_varids(ncid)]


"""
    ds = dataset(var::Variable)
    ds = NCDataset(var::Variable)

Return the `NCDataset` containing the variable `var`.
"""
dataset(var::Variable) = var.ds

# old function call, replace by CommonDataModel.dataset
NCDataset(v::AbstractNCVariable) = dataset(v)

"""
    sz = size(var::Variable)

Return a tuple of integers with the size of the variable `var`.

!!! note

    Note that the size of a variable can change, i.e. for a variable with an
    unlimited dimension.
"""
Base.size(v::Variable{T,N}) where {T,N} = ntuple(i -> nc_inq_dimlen(v.ds.ncid,v.dimids[i]),Val(N))


"""
    renameVar(ds::NCDataset,oldname,newname)

Rename the variable called `oldname` to `newname`.
"""
function renameVar(ds::NCDataset,oldname::AbstractString,newname::AbstractString)
    # make sure that the file is in define mode
    defmode(ds)
    varid = nc_inq_varid(ds.ncid,oldname)
    nc_rename_var(ds.ncid,varid,newname)
    return nothing
end
export renameVar


############################################################
# Obtaining variables
############################################################

function variable(ds::NCDataset,varid::Integer)
    dimids = nc_inq_vardimid(ds.ncid,varid)
    nctype = _jltype(ds.ncid,nc_inq_vartype(ds.ncid,varid))
    ndims = length(dimids)

    # reverse dimids to have the dimension order in Fortran style
    return Variable{nctype,ndims,typeof(ds)}(ds,varid, (reverse(dimids)...,))
end


function _variable(ds::NCDataset,varname)
    varid = nc_inq_varid(ds.ncid,varname)
    return variable(ds,varid)
end

"""
    v = variable(ds::NCDataset,varname::String)

Return the NetCDF variable `varname` in the dataset `ds` as a
`NCDataset.Variable`. No scaling or other transformations are applied when the
variable `v` is indexed.
"""
variable(ds::NCDataset,varname::AbstractString) = _variable(ds,varname)
variable(ds::NCDataset,varname::Symbol) = _variable(ds,varname)

export variable


function checkbuffer(len,data)
    if length(data) != len
        throw(DimensionMismatch("expected an array with $(len) elements, but got an arrow with $(length(data)) elements"))
    end
end

@inline function unsafe_load!(ncvar::Variable, data, indices::Union{Integer, UnitRange, StepRange, CartesianIndex, CartesianIndices, Colon}...)
    sizes = size(ncvar)
    ind = to_indices(ncvar,indices)

    start,count,stride,jlshape = ncsub(ncvar,ind)

    @boundscheck begin
        checkbounds(ncvar,indices...)
        checkbuffer(prod(count),data)
    end

    nc_get_vars!(ncvar.ds.ncid,ncvar.varid,start,count,stride,data)
end

"""
    NCDatasets.load!(ncvar::Variable, data, indices)

Loads a NetCDF variables `ncvar` in-place and puts the result in `data` along the
specified `indices`. One can use @inbounds annotate code where
bounds checking can be elided by the compiler (which typically require
type-stable code).

```julia
using NCDatasets
ds = NCDataset("file.nc")
ncv = ds["vgos"].var;
# data must have the right shape and type
data = zeros(eltype(ncv),size(ncv));
NCDatasets.load!(ncv,data,:,:,:)
# or
# @inbounds NCDatasets.load!(ncv,data,:,:,:)
close(ds)

# loading a subset
data = zeros(5); # must have the right shape and type
load!(ds["temp"].var,data,:,1) # loads the 1st column
```

!!! note

    For a netCDF variable of type `NC_CHAR`, the element type of the `data`
    array must be `UInt8` and cannot be the julia `Char` type, because the
    julia `Char` type uses 4 bytes and the NetCDF `NC_CHAR` only 1 byte.
"""
@inline function load!(ncvar::Variable{T,N}, data::AbstractArray{T}, indices::Union{Integer, UnitRange, StepRange, CartesianIndex, CartesianIndices, Colon}...) where {T,N}
    unsafe_load!(ncvar, data, indices...)
end

@inline function load!(ncvar::Variable{Char,N}, data::AbstractArray{UInt8}, indices::Union{Integer, UnitRange, StepRange, Colon}...) where N
    unsafe_load!(ncvar, data, indices...)
end

@inline function load!(ncvar::Variable{T,2}, data::AbstractArray{T}, i::Colon,j::UnitRange) where T
    # reversed and 0-based
    start = [first(j)-1,0]
    count = [length(j),size(ncvar,1)]

    @boundscheck begin
        checkbounds(ncvar,i,j)
        checkbuffer(prod(count),data)
    end

    nc_get_vara!(ncvar.ds.ncid,ncvar.varid,start,count,data)
end


"""
     data = loadragged(ncvar,index::Union{Colon,UnitRange,Integer})

Load data from `ncvar` in the [contiguous ragged array representation](https://web.archive.org/web/20190111092546/http://cfconventions.org/cf-conventions/v1.6.0/cf-conventions.html#_contiguous_ragged_array_representation) as a
vector of vectors. It is typically used to load a list of profiles
or time series of different length each.

The [indexed ragged array representation](https://web.archive.org/web/20190111092546/http://cfconventions.org/cf-conventions/v1.6.0/cf-conventions.html#_indexed_ragged_array_representation) is currently not supported.
"""
function loadragged(ncvar,index::Union{Colon,UnitRange})
    ds = dataset(ncvar)

    dimensionnames = dimnames(ncvar)
    if length(dimensionnames) !== 1
        throw(NetCDFError(-1, "NetCDF variable $(name(ncvar)) should have only one dimensions"))
    end
    dimname = dimensionnames[1]

    ncvarsizes = varbyattrib(ds,sample_dimension = dimname)
    if length(ncvarsizes) !== 1
        throw(NetCDFError(-1, "There should be exactly one NetCDF variable with the attribute 'sample_dimension' equal to '$(dimname)'"))
    end

    # ignore _FillValue which can be 0 for WOD
    ncvarsize = ncvarsizes[1].var

    isa(index,Colon)||(index[1]==1) ? n0=1 : n0=1+sum(ncvarsize[1:index[1]-1])
    isa(index,Colon) ? n1=sum(ncvarsize[:]) : n1=sum(ncvarsize[1:index[end]])

    varsize = ncvarsize[index]

    istart = 0;
    tmp = ncvar[n0:n1]

    T = typeof(view(tmp,1:varsize[1]))
    data = Vector{T}(undef,length(varsize))

    for i in eachindex(varsize,data)
        data[i] = view(tmp,istart+1:istart+varsize[i]);
        istart += varsize[i]
    end
    return data
end

loadragged(ncvar,index::Integer) = loadragged(ncvar,index:index)

export loadragged



############################################################
# User API regarding Variables
############################################################
"""
    dimnames(v::Variable)

Return a tuple of strings with the dimension names of the variable `v`.
"""
function dimnames(v::Variable{T,N}) where {T,N}
    return ntuple(i -> nc_inq_dimname(v.ds.ncid,v.dimids[i]),Val(N))
end
export dimnames

"""
    name(v::Variable)

Return the name of the NetCDF variable `v`.
"""
name(v::Variable) = nc_inq_varname(v.ds.ncid,v.varid)
export name

chunking(v::Variable,storage,chunksizes) = nc_def_var_chunking(v.ds.ncid,v.varid,storage,reverse(collect(chunksizes)))

"""
    storage,chunksizes = chunking(v::Variable)

Return the storage type (`:contiguous` or `:chunked`) and the chunk sizes
of the varable `v`.
Note that `chunking` reports the same information as `nc_inq_var_chunking` and
therefore [considers variables with unlimited dimension as `:contiguous`](https://github.com/Unidata/netcdf-c/discussions/2224).
"""
function chunking(v::Variable)
    storage,chunksizes = nc_inq_var_chunking(v.ds.ncid,v.varid)
    # TODO: NCDatasets 0.14: return a tuple for chunksizes
    return storage,reverse(chunksizes)
end


export chunking

# same as `chunking` except that for NetCDF3 file the unlimited dimension is considered
# as chunked
# https://github.com/Unidata/netcdf-c/discussions/2224
# Also the chunksizes is always a tuple.
function _chunking(v::Variable{T,N}) where {T,N}
    ncid = v.ds.ncid
    varid = v.varid
    sz = size(v)

    format = nc_inq_format(ncid)

    if format in (NC_FORMAT_NC3, NC_FORMAT_64BIT, NC_FORMAT_CDF5)
        # normally there should be max. 1 unlimited dimension for NetCDF 3 files
        unlimdim_ids = nc_inq_unlimdims(ncid)

        if length(unlimdim_ids) > 0
            dimids = reverse(nc_inq_vardimid(ncid,varid))

            if !isempty(intersect(dimids,unlimdim_ids))

                chunksizes = ntuple(N) do i
                    if dimids[i] in unlimdim_ids
                        1
                    else
                        sz[i]
                    end
                end

                return :chunked, chunksizes
            end
        end
    end

    storage,chunksizes = chunking(v)
    return storage,NTuple{N}(chunksizes)
end

_chunking(v::CFVariable{T,N,<:Variable}) where {T,N} = _chunking(v.var)

function _chunking(v)
    storage,chunksizes = chunking(v)
    return storage,Tuple(chunksizes)
end

"""
    isshuffled,isdeflated,deflate_level = deflate(v::Variable)

Return compression information of the variable `v`. If shuffle
is `true`, then shuffling (byte interlacing) is activated. If
deflate is `true`, then the data chunks (see `chunking`) are
compressed using the compression level `deflate_level`
(0 means no compression and 9 means maximum compression).
"""
deflate(v::Variable,shuffle,deflate,deflate_level) = nc_def_var_deflate(v.ds.ncid,v.varid,shuffle,deflate,deflate_level)
deflate(v::Variable) = nc_inq_var_deflate(v.ds.ncid,v.varid)
export deflate

checksum(v::Variable,checksummethod) = nc_def_var_fletcher32(v.ds.ncid,v.varid,checksummethod)

"""
    checksummethod = checksum(v::Variable)

Return the checksum method of the variable `v` which can be either
be `:fletcher32` or `:nochecksum`.
"""
checksum(v::Variable) = nc_inq_var_fletcher32(v.ds.ncid,v.varid)
export checksum

function fillmode(v::Variable)
    no_fill,fv = nc_inq_var_fill(v.ds.ncid, v.varid)
    return no_fill,fv
end
export fillmode

"""
    fv = fillvalue(v::Variable)
    fv = fillvalue(v::CFVariable)

Return the fill-value of the variable `v`.
"""
function fillvalue(v::Variable{NetCDFType,N}) where {NetCDFType,N}
    no_fill,fv = nc_inq_var_fill(v.ds.ncid, v.varid)
    return fv::NetCDFType
end
export fillvalue


paraccess() = error("This function is available after importing MPI")

"""
    a = nomissing(da)

Return the values of the array `da` of type `Array{Union{T,Missing},N}`
(potentially containing missing values) as a regular Julia array `a` of the same
element type. It raises an error if the array contains at least one missing value.

"""
function nomissing(da::AbstractArray{Union{T,Missing},N}) where {T,N}
    if any(ismissing, da)
        error("arrays contains missing values (values equal to the fill values attribute in the NetCDF file)")
    end
    if VERSION >= v"1.2"
        # Illegal instruction (core dumped) in Julia 1.0.5
        # but works on Julia 1.2
        return Array{T,N}(da)
    else
        # old
        if isempty(da)
            return Array{T,N}([])
        else
            return replace(da, missing => da[1])
        end
    end
end

nomissing(a::AbstractArray) = a

"""
    a = nomissing(da,value)

Retun the values of the array `da` of type `AbstractArray{Union{T,Missing},N}`
as a regular Julia array `a` by replacing all missing value by `value`
(converted to type `T`).
This function is identical to `coalesce.(da,T(value))` where T is the element
type of `da`.
## Example:

```julia-repl
julia> nomissing([missing,1.,2.],NaN)
# returns [NaN, 1.0, 2.0]
```
"""
function nomissing(da::AbstractArray{Union{T,Missing},N},value) where {T,N}
    return replace(da, missing => T(value))
end

nomissing(a::AbstractArray,value) = a
export nomissing


# It is important that this method is more specific that the generic
# DiskArrays.readblock! for vector indices which is slower
# (see https://github.com/Alexander-Barth/NCDatasets.jl/pull/205#issuecomment-1589575041)

function readblock!(v::Variable, aout, indexes::AbstractRange...)
    datamode(v.ds)
    _read_data_from_nc!(v, aout, indexes...)
    return aout
end

readblock!(v::Variable, aout) = _read_data_from_nc!(v::Variable, aout)

function _read_data_from_nc!(v::Variable, aout, indexes::Integer...)
    aout .= nc_get_var1(eltype(v),v.ds.ncid,v.varid,[i-1 for i in reverse(indexes)])
end

function _read_data_from_nc!(v::Variable{T,N}, aout, indexes::TR...) where {T,N} where TR <: Union{StepRange{<:Integer,<:Integer},UnitRange{<:Integer}}
    start,count,stride,jlshape = ncsub(v,indexes)
    nc_get_vars!(v.ds.ncid,v.varid,start,count,stride,aout)
end

function _read_data_from_nc!(v::Variable{T,N}, aout, indexes::Union{Integer,Colon,AbstractRange{<:Integer}}...) where {T,N}
    start,count,stride,jlshape = ncsub(v,indexes)
    nc_get_vars!(v.ds.ncid,v.varid,start,count,stride,aout)
end

_read_data_from_nc!(v::Variable, aout) = _read_data_from_nc!(v, aout, 1)

function writeblock!(v::Variable, data, indexes::AbstractRange...)
    datamode(v.ds)
    _write_data_to_nc(v, data, indexes...)
    return data
end

function _write_data_to_nc(v::Variable{T,N},data,indexes::Integer...) where {T,N}
    nc_put_var1(v.ds.ncid,v.varid,[i-1 for i in reverse(indexes)],T(data[1]))
end

_write_data_to_nc(v::Variable, data) = _write_data_to_nc(v, data, 1)

function _write_data_to_nc(v::Variable{T}, data, indexes::AbstractRange{<:Integer}...) where T
    ind = prod(length.(indexes)) == 1 ? first.(indexes) : to_indices(v,indexes)

    start,count,stride,jlshape = ncsub(v,indexes)
    return nc_put_vars(v.ds.ncid,v.varid,start,count,stride,T.(data))
end

# materialize disk arrays
function _write_data_to_nc(v::Variable{T,N},data::DiskArrays.AbstractDiskArray,indexes::Integer...) where {T,N}
    return _write_data_to_nc(v,Array(data),indexes...)
end

function _write_data_to_nc(v::Variable{T}, data::DiskArrays.AbstractDiskArray, indexes::AbstractRange{<:Integer}...) where T
    return _write_data_to_nc(v,Array(data),indexes...)
end

function eachchunk(v::Variable)
    # storage will be reported as chunked for variables with unlimited dimension
    # by _chunking and chunksizes will 1 for the unlimited dimensions
    storage, chunksizes = _chunking(v)
    if storage == :contiguous
        return DiskArrays.estimate_chunksize(v)
    else
        return DiskArrays.GridChunks(v, chunksizes)
    end
end
haschunks(v::Variable) = (_chunking(v)[1] == :contiguous ? DiskArrays.Unchunked(DiskArrays.SubRanges(DiskArrays.CanStepRange(),1.0)) : 
    DiskArrays.Chunked(DiskArrays.SubRanges(DiskArrays.CanStepRange(),1.0)))

eachchunk(v::CFVariable{T,N,<:Variable}) where {T,N} = eachchunk(v.var)
haschunks(v::CFVariable{T,N,<:Variable}) where {T,N} = haschunks(v.var)

# computes the size of the array `a` after applying the indexes
# size(a[indexes...]) == size_getindex(a,indexes...)

# Note there can more indices than dimension, e.g.
# size(zeros(3,3)[:,:,1:1]) == (3,3,1)
# the difficulty here is to make the size inferrable by the compiler

@inline size_getindex(array,indexes...) = _size_getindex(array,(),1,indexes...)
@inline _size_getindex(array,sh,n,i::Integer,indexes...) = _size_getindex(array,sh,                   n+1,indexes...)
@inline _size_getindex(array::AbstractArray,sh,n,i::Colon,  indexes...) = _size_getindex(array,(sh...,size(array,n)),n+1,indexes...)
@inline _size_getindex(sz::Tuple,sh,n,i::Colon,  indexes...) = _size_getindex(sz,(sh...,sz[n]),n+1,indexes...)
@inline _size_getindex(array,sh,n,i,         indexes...) = _size_getindex(array,(sh...,length(i)),    n+1,indexes...)
@inline _size_getindex(array,sh,n) = sh


@inline start_count_stride(n,ind::AbstractRange) = (first(ind)-1,length(ind),step(ind))
@inline start_count_stride(n,ind::Integer) = (ind-1,1,1)
@inline start_count_stride(n,ind::Colon) = (0,n,1)

@inline function ncsub(v,indexes)
    sz = size(v)
    N = length(sz)

    start = Vector{Int}(undef,N)
    count = Vector{Int}(undef,N)
    stride = Vector{Int}(undef,N)

    for i = 1:N
        ind = indexes[i]
        ri = N-i+1
        @inbounds start[ri],count[ri],stride[ri] = start_count_stride(sz[i],ind)
    end

    jlshape = size_getindex(v,indexes...)

    return start,count,stride,jlshape
end



# indexing with vector of integers

to_range_list(index::Integer,len) = index

to_range_list(index::Colon,len) = [1:len]
to_range_list(index::AbstractRange,len) = [index]

function to_range_list(index::Vector{T},len) where T <: Integer
    grow(istart) = istart[begin]:(istart[end]+step(istart))

    baseindex = 1
    indices_ranges = UnitRange{T}[]

    while baseindex <= length(index)
        range = index[baseindex]:index[baseindex]
        range_test = grow(range)
        index_view = @view index[baseindex:end]

        while checkbounds(Bool,index_view,length(range_test)) &&
            (range_test[end] == index_view[length(range_test)])

            range = range_test
            range_test = grow(range_test)
        end

        push!(indices_ranges,range)
        baseindex += length(range)
    end

    @assert reduce(vcat,indices_ranges,init=T[]) == index
    return indices_ranges
end

_range_indices_dest(of) = of
_range_indices_dest(of,i::Integer,rest...) = _range_indices_dest(of,rest...)

function _range_indices_dest(of,v,rest...)
    b = 0
    ind = similar(v,0)
    for r in v
        rr = 1:length(r)
        push!(ind,b .+ rr)
        b += length(r)
    end

    _range_indices_dest((of...,ind),rest...)
end
range_indices_dest(ri...) = _range_indices_dest((),ri...)

