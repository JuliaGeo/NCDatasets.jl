############################################################
# Creating variables
############################################################

"""
    defVar(ds::NCDataset,name,vtype,dimnames; kwargs...)
    defVar(ds::NCDataset,name,data,dimnames; kwargs...)

Define a variable with the name `name` in the dataset `ds`.  `vtype` can be
Julia types in the table below (with the corresponding NetCDF type). The
parameter `dimnames` is a tuple with the names of the dimension.  For scalar
this parameter is the empty tuple `()`.
The variable is returned (of the type `CFVariable`).

Instead of providing the variable type one can directly give also the data `data` which
will be used to fill the NetCDF variable. In this case, the dimensions with
the appropriate size will be created as required using the names in `dimnames`.

If `data` is a vector or array of `DateTime` objects, then the dates
are saved as double-precision floats and units
"$(CFTime.DEFAULT_TIME_UNITS)" (unless a time unit
is specifed with the `attrib` keyword as described below). Dates are
converted to the default calendar in the CF conversion which is the
mixed Julian/Gregorian calendar.

## Keyword arguments

* `fillvalue`: A value filled in the NetCDF file to indicate missing data.
   It will be stored in the _FillValue attribute. `NCDatasets` does not use implicitely the default NetCDF fill values when reading data.
* `chunksizes`: Vector integers setting the chunk size. The total size of a chunk must be less than 4 GiB.
* `deflatelevel`: Compression level: 0 (default) means no compression and 9 means maximum compression. Each chunk will be compressed individually.
* `shuffle`: If true, the shuffle filter is activated which can improve the compression ratio.
* `checksum`: The checksum method can be `:fletcher32` or `:nochecksum` (checksumming is disabled, which is the default)
* `attrib`: An iterable of attribute name and attribute value pairs, for example a `Dict`, `DataStructures.OrderedDict` or simply a vector of pairs (see example below)
* `typename` (string): The name of the NetCDF type required for [vlen arrays](https://web.archive.org/save/https://www.unidata.ucar.edu/software/netcdf/netcdf-4/newdocs/netcdf-c/nc_005fdef_005fvlen.html)

`chunksizes`, `deflatelevel`, `shuffle` and `checksum` can only be
set on NetCDF 4 files. Compression of strings and variable-length arrays is not
supported by the underlying NetCDF library.

## NetCDF data types

| NetCDF Type | Julia Type |
|-------------|------------|
| NC_BYTE     | Int8 |
| NC_UBYTE    | UInt8 |
| NC_SHORT    | Int16 |
| NC_INT      | Int32 |
| NC_INT64    | Int64 |
| NC_FLOAT    | Float32 |
| NC_DOUBLE   | Float64 |
| NC_CHAR     | Char |
| NC_STRING   | String |


## Dimension ordering

The data is stored in the NetCDF file in the same order as they are stored in
memory. As julia uses the
[Column-major ordering](https://en.wikipedia.org/wiki/Row-_and_column-major_order)
for arrays, the order of dimensions will appear reversed when the data is loaded
in languages or programs using
[Row-major ordering](https://en.wikipedia.org/wiki/Row-_and_column-major_order)
such as C/C++, Python/NumPy or the tools `ncdump`/`ncgen`
([NetCDF CDL](https://web.archive.org/web/20220513091844/https://docs.unidata.ucar.edu/nug/current/_c_d_l.html)).
NumPy can also use Column-major ordering but Row-major order is the default. For the column-major
interpretation of the dimensions (as in Julia), the
[CF Convention recommends](https://web.archive.org/web/20220328110810/http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html#dimensions) the
order  "longitude" (X), "latitude" (Y), "height or depth" (Z) and
"date or time" (T) (if applicable). All other dimensions should, whenever
possible, be placed to the right of the spatiotemporal dimensions.

## Example:

In this example, `scale_factor` and `add_offset` are applied when the `data`
is saved.

```julia-repl
julia> using DataStructures
julia> data = randn(3,5)
julia> NCDataset("test_file.nc","c") do ds
          defVar(ds,"temp",data,("lon","lat"), attrib = OrderedDict(
             "units" => "degree_Celsius",
             "add_offset" => -273.15,
             "scale_factor" => 0.1,
             "long_name" => "Temperature"
          ))
       end;
```

!!! note

    If the attributes `_FillValue`, `missing_value`, `add_offset`, `scale_factor`,
    `units` and `calendar` are used, they should be defined when calling `defVar`
    by using the parameter `attrib` as shown in the example above.


"""
function defVar(ds::NCDataset,name::SymbolOrString,vtype::DataType,dimnames;
                chunksizes = nothing,
                shuffle = false,
                deflatelevel = nothing,
                checksum = nothing,
                fillvalue = nothing,
                nofill = false,
                typename = nothing,
                attrib = ())
     # make sure that the file is in define mode
    defmode(ds) do
        dimids = Cint[nc_inq_dimid(ds.ncid,dimname) for dimname in dimnames[end:-1:1]]

        typeid =
            if vtype <: Vector
                # variable-length type
                typeid = nc_def_vlen(ds.ncid, typename, ncType[eltype(vtype)])
            else
                # base-type
                haskey(ncType, vtype) || error("$vtype not supported")
                ncType[vtype]
            end

        varid = nc_def_var(ds.ncid,name,typeid,dimids)

        if chunksizes !== nothing
            storage = :chunked
            # this will fail on NetCDF-3 files
            nc_def_var_chunking(ds.ncid,varid,storage,reverse(chunksizes))
        end

        if shuffle || (deflatelevel !== nothing)
            deflate = deflatelevel !== nothing

            # this will fail on NetCDF-3 files
            nc_def_var_deflate(ds.ncid,varid,shuffle,deflate,deflatelevel)
        end

        if checksum !== nothing
            nc_def_var_fletcher32(ds.ncid,varid,checksum)
        end

        if fillvalue !== nothing
            nc_def_var_fill(ds.ncid, varid, nofill, vtype(fillvalue))
        end

        v = ds[name]
        for (attname,attval) in attrib
            @debug "variable $name: setting $attname" attval typeof(attval) eltype(v)
            v.attrib[attname] = attval
        end
    end

    # note: element type of ds[name] potentially changed
    # we cannot return v here
    return ds[name]
end


function defVar(dest::AbstractDataset,srcvar::AbstractNCVariable; kwargs...)
    _ignore_checksum = false
    if haskey(kwargs,:checksum)
        _ignore_checksum = kwargs[:checksum] === nothing
    end

    src = dataset(srcvar)
    varname = name(srcvar)

    # dimensions
    unlimited_dims = unlimited(src)

    for dimname in dimnames(srcvar)
        if dimname in dimnames(dest,parents = true)
            # dimension is already defined
            continue
        end

        if dimname in unlimited_dims
            defDim(dest, dimname, Inf)
        else
            defDim(dest, dimname, dim(src,dimname))
        end
    end

    var = variable(src,varname)
    dimension_names = dimnames(var)
    cfdestvar = defVar(dest, varname, eltype(var), dimension_names;
                       attrib = attribs(var))
    destvar = variable(dest,varname)

    if hasmethod(chunking,Tuple{typeof(var)})
        storage,chunksizes = chunking(var)
        @debug "chunking " name(var) size(var) size(cfdestvar) storage chunksizes
        chunking(cfdestvar,storage,chunksizes)
    end

    if hasmethod(deflate,Tuple{typeof(var)})
        isshuffled,isdeflated,deflate_level = deflate(var)
        @debug "compression" isshuffled isdeflated deflate_level
        deflate(cfdestvar,isshuffled,isdeflated,deflate_level)
    end

    if hasmethod(checksum,Tuple{typeof(var)}) && !_ignore_checksum
        checksummethod = checksum(var)
        @debug "check-sum" checksummethod
        checksum(cfdestvar,checksummethod)
    end

    # copy data
    if hasmethod(eachchunk,Tuple{typeof(var)})
        for indices in eachchunk(var)
            destvar[indices...] = var[indices...]
        end
    else
        indices = ntuple(i -> :,ndims(var))
        destvar[indices...] = var[indices...]
    end

    return cfdestvar
end

export defVar


# more efficient implementation implementing a cache
function boundsParentVar(ds::AbstractNCDataset,varname)
    # iterating using variable ids instead of variable names
    # is more efficient (but not possible for e.g. multi-file datasets)
    eachvariable(ds::NCDataset) = (variable(ds,varid) for varid in nc_inq_varids(ds.ncid))
    eachvariable(ds) = (variable(ds,vname) for vname in keys(ds))


    # get from cache is available
    if length(values(ds._boundsmap)) > 0
        return get(ds._boundsmap,varname,"")
    else
        for v in eachvariable(ds)
            bounds = get(v.attrib,"bounds","")
            if bounds === varname
                return name(v)
            end
        end

        return ""
    end
end


export cfvariable

"""
    dimsize(v::CFVariable)
Get the size of a `CFVariable` as a named tuple of dimension → length.
"""
function dimsize(v::Union{CFVariable{T,N,<:Variable},MFCFVariable,SubVariable}) where {T,N}
    s = size(v)
    names = Symbol.(dimnames(v))
    return NamedTuple{names}(s)
end


export dimsize
