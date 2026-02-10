

const NCIterable = AbstractNCDataset
Base.length(a::NCIterable) = length(keys(a))


############################################################
# Mappings
############################################################

# Mapping between NetCDF types and Julia types
const jlType = Dict(
    NC_BYTE   => Int8,
    NC_UBYTE  => UInt8,
    NC_SHORT  => Int16,
    NC_USHORT => UInt16,
    NC_INT    => Int32,
    NC_UINT   => UInt32,
    NC_INT64  => Int64,
    NC_UINT64 => UInt64,
    NC_FLOAT  => Float32,
    NC_DOUBLE => Float64,
    NC_CHAR   => Char,
    NC_STRING => String
)

# Inverse mapping
const ncType = Dict(value => key for (key, value) in jlType)

iswritable(ds::NCDataset) = ds.iswritable
maskingvalue(ds::NCDataset) = ds.maskingvalue

function isopen(ds::NCDataset)
    try
        dspath = path(ds)
        return true
    catch err
        if isa(err,NetCDFError)
            if err.code == NC_EBADID
                return false
            end
        end
        rethrow()
    end
end

function datamode(ds::Dataset)
    if ds.isdefmode[]
        nc_enddef(ds.ncid)
        ds.isdefmode[] = false
    end
end

"""
    datamode(f::Function,ds::Dataset)

Make sure that a dataset `is` in data mode when executing the function `f`.
The call of `f` is protected using a reentrant lock for thread-safety.
"""
function datamode(f::Function,ds::Dataset)
    lock(ds.lock) do
        datamode(ds)
        f()
    end
end

function defmode(ds::Dataset)
    if !ds.isdefmode[]
        nc_redef(ds.ncid)
        ds.isdefmode[] = true
    end
end

"""
    defmode(f::Function,ds::Dataset)

Make sure that a dataset `is` in define mode when executing the function `f`.
The call of `f` is protected using a reentrant lock for thread-safety.
"""
function defmode(f::Function,ds::Dataset)
    lock(ds.lock) do
        defmode(ds)
        f()
    end
end



function NCDataset(ncid::Integer,
                   iswritable::Bool,
                   isdefmode::Array{Bool,0};
                   parentdataset = nothing,
                   maskingvalue = missing,
                   )

    function _finalize(ds)
        # only close open root group
        if (ds.ncid != -1) && (ds.parentdataset == nothing)
            close(ds)
        end
    end
    @debug "maskingvalue" maskingvalue
    ds = NCDataset{typeof(parentdataset),typeof(maskingvalue)}(
        parentdataset,
        ncid,
        iswritable,
        isdefmode,
        Dict{String,String}(),
        maskingvalue,
        ReentrantLock(),
    )

    if !iswritable
        initboundsmap!(ds)
    end

    finalizer(_finalize, ds)
    return ds
end

function _dataset_ncmode(filename,mode,format;
                         diskless::Bool = false,
                         persist::Bool = false,
                         share::Bool = false)

    ncmode =
        if mode == "r"
            NC_NOWRITE
        elseif mode == "a"
            NC_WRITE
        elseif mode == "c"
            NC_CLOBBER
        else
            throw(NetCDFError(-1, "Unsupported mode '$(mode)' for filename '$(filename)'"))
        end

    if diskless
        ncmode = ncmode | NC_DISKLESS

        if persist
            ncmode = ncmode | NC_PERSIST
        end
    end

    if share
        @debug "share mode"
        ncmode = ncmode | NC_SHARE
    end

    if format == :netcdf5_64bit_data
        ncmode = ncmode | NC_64BIT_DATA
    elseif format == :netcdf3_64bit_offset
        ncmode = ncmode | NC_64BIT_OFFSET
    elseif format == :netcdf4_classic
        ncmode = ncmode | NC_NETCDF4 | NC_CLASSIC_MODEL
    elseif format == :netcdf4
        ncmode = ncmode | NC_NETCDF4
    elseif format == :netcdf3_classic
        # do nothing
    else
        throw(NetCDFError(-1, "Unkown format '$(format)' for filename '$(filename)'"))
    end

    return ncmode
end

############################################################
# High-level
############################################################

"""
    NCDataset(filename::AbstractString, mode = "r";
              format::Symbol = :netcdf4,
              share::Bool = false,
              diskless::Bool = false,
              persist::Bool = false,
              memory::Union{Vector{UInt8},Nothing} = nothing,
              attrib = [])

Load, create or overwrite a NetCDF file at `filename`, depending on `mode`

* `"r"` (default) : open an existing netCDF file or OPeNDAP URL
   in read-only mode.
* `"c"` : create a new NetCDF file at `filename` (an existing file with the same
  name will be overwritten).
* `"a"` : open `filename` into append mode (i.e. existing data in the netCDF
  file is not overwritten and a variable can be added).


If `share` is true, the `NC_SHARE` flag is set allowing to have multiple
processes to read the file and one writer process (netcdf classic files only).
Likewise setting `diskless` or `persist` to `true` will enable the flags
`NC_DISKLESS` or `NC_PERSIST` flag.
More information is available in the [NetCDF C-API](https://www.unidata.ucar.edu/software/netcdf/docs/).

Notice that this does not close the dataset, use `close` on the
result (or see below the `do`-block).

The optional parameter `attrib` is an iterable of attribute name and attribute
value pairs, for example a `Dict`, `DataStructures.OrderedDict` or simply a
vector of pairs (see example below).

# Supported `format` values:

* `:netcdf4` (default): HDF5-based NetCDF format.
* `:netcdf4_classic`: Only netCDF 3 compatible API features will be used.
* `:netcdf3_classic`: classic netCDF format supporting only files smaller than 2GB.
* `:netcdf3_64bit_offset`: improved netCDF format supporting files larger than 2GB.
* `:netcdf5_64bit_data`: improved netCDF format supporting 64-bit integer data types.


Files can also be open and automatically closed with a `do` block.

```julia
NCDataset("file.nc") do ds
    data = ds["temperature"][:,:]
end
```

Here is an attribute example:
```julia
using DataStructures
NCDataset("file.nc", "c", attrib = OrderedDict("title" => "my first netCDF file")) do ds
   defVar(ds,"temp",[10.,20.,30.],("time",))
end;
```

The NetCDF dataset can also be a `memory` as a vector of bytes. A non-empty string
a `filename` is still required, for example:

```julia
using NCDataset, HTTP
resp = HTTP.get("https://www.unidata.ucar.edu/software/netcdf/examples/ECMWF_ERA-40_subset.nc")
ds = NCDataset("some_string","r",memory = resp.body)
total_precipitation = ds["tp"][:,:,:]
close(ds)
```

`Dataset` is an alias of `NCDataset`.
"""
function NCDataset(filename::AbstractString,
                   mode::AbstractString = "r";
                   format::Symbol = :netcdf4,
                   share::Bool = false,
                   diskless::Bool = false,
                   persist::Bool = false,
                   memory::Union{Vector{UInt8},Nothing} = nothing,
                   maskingvalue = missing,
                   attrib = [])

    ncid = -1
    isdefmode = fill(false)
    ncmode = _dataset_ncmode(filename,mode,format;
                             diskless = diskless,
                             persist = persist,
                             share = share)

    @debug "ncmode: $ncmode"

    if (mode == "r") || (mode == "a")
        if memory == nothing
            ncid = nc_open(filename,ncmode)
        else
            ncid = nc_open_mem(filename,ncmode,memory)
        end
    elseif mode == "c"
        ncid = nc_create(filename,ncmode)
        isdefmode[] = true
    end

    iswritable = mode != "r"
    ds = NCDataset(
        ncid,iswritable,isdefmode,
        maskingvalue = maskingvalue)

    # set global attributes
    for (attname,attval) in attrib
        ds.attrib[attname] = attval
    end

    return ds
end


function NCDataset(f::Function,args...; kwargs...)
    ds = NCDataset(args...; kwargs...)
    try
        f(ds)
    finally
        @debug "closing netCDF NCDataset $(ds.ncid) $(NCDatasets.path(ds))"
        close(ds)
    end
end

export NCDataset, Dataset

############################################################
# High-level: user convenience
############################################################
"""
    keys(ds::NCDataset)

Return a list of all variables names in NCDataset `ds`.
"""
varnames(ds::NCDataset) = listVar(ds.ncid)

"""
    path(ds::NCDataset)

Return the file path (or the opendap URL) of the NCDataset `ds`
"""
path(ds::NCDataset) = nc_inq_path(ds.ncid)
export path


"""
    sync(ds::NCDataset)

Write all changes in NCDataset `ds` to the disk.
"""
function sync(ds::NCDataset)
    datamode(ds) do
        nc_sync(ds.ncid)
    end
end
export sync

"""
    close(ds::NCDataset)

Close the NCDataset `ds`. All pending changes will be written
to the disk.
"""
function Base.close(ds::NCDataset)
    #@debug "closing netCDF NCDataset $(ds.ncid) $(NCDatasets.path(ds))"
    try
        nc_close(ds.ncid)
    catch err
        # like Base, allow close on closed file
        if isa(err,NetCDFError)
            if err.code == NC_EBADID
                return ds
            end
        end
        rethrow()
    end
    # prevent finalize to close file as ncid can reused for future files
    ds.ncid = -1
    return ds
end
export close

############################################################
# Common methods
############################################################
function Base.iterate(a::NCIterable, state = keys(a))
    if length(state) == 0
        return nothing
    end

    return (state[1] => a[popfirst!(state)], state)
end

export varbyattrib



"""
    haskey(ds::NCDataset,name)
    haskey(d::Dimensions,name)
    haskey(ds::Attributes,name)

Return true if the NCDataset `ds` (or dimension/attribute list) has a variable (dimension/attribute) with the name `name`.
For example:

```julia
ds = NCDataset("/tmp/test.nc","r")
if haskey(ds,"temperature")
    println("The file has a variable 'temperature'")
end

if haskey(ds.dim,"lon")
    println("The file has a dimension 'lon'")
end
```

This example checks if the file `/tmp/test.nc` has a variable with the
name `temperature` and a dimension with the name `lon`.
"""
Base.haskey(a::NCIterable,name::AbstractString) = name in keys(a)

"""
    names = dimnames(ds::AbstractNCDataset; parents = false)

Return all names defined in `ds`. When `parents` is `true`,
also the names of parent groups are returned (default is `false`).
"""
function dimnames(ds::AbstractNCDataset; parents = false)
    dn = keys(ds.dim)

    if parents
        pd = parentdataset(ds)
        if pd !== nothing
            append!(dn,dimnames(pd,parents=parents))
        end
    end

    return dn
end

"""
    len = dim(ds::AbstractNCDataset,name::SymbolOrString)

Return the (current) length of the dimension `name` of the dataset `ds`.
"""
dim(ds::AbstractNCDataset,name::SymbolOrString) = ds.dim[name]


function Base.write(dest_filename::AbstractString, src::AbstractDataset; kwargs...)
    NCDataset(dest_filename,"c") do dest
        write(dest,src; kwargs...)
    end
    return nothing
end


get_chunk_cache() = nc_get_chunk_cache()

function set_chunk_cache(;size=nothing,nelems=nothing,preemption=nothing)
    size_orig,nelems_orig,preemption_orig = nc_get_chunk_cache()
    size = (isnothing(size) ? size_orig : size)
    nelems = (isnothing(nelems) ? nelems_orig : nelems)
    preemption = (isnothing(preemption) ? preemption_orig : preemption)
    nc_set_chunk_cache(size,nelems,preemption)
end
