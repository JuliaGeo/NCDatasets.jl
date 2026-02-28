"""
NCDatasets is a module to read and write NetCDF files.
This is minimal example how to read a NetCDF file.

```julia
using NCDatasets
# open the file and show its metadata (if called in the REPL without ending semicolon)
ds = NCDataset("filename.nc","r")
# load all data of the variable temperature
v = ds["temperature"][:,:]
# load the attribute units
unit = v.attrib["units"]
# close the file
close(ds)
```

More information is available at https://github.com/JuliaGeo/NCDatasets.jl .
"""
module NCDatasets

import Base: Array, close, collect, convert, delete!, display, filter, getindex,
    parent, parentindices, setindex!, show, showerror, size, view, cat
using CFTime
using DataStructures: OrderedDict
using Dates
using NetCDF_jll
using NetworkOptions
using Printf
using CommonDataModel
using CommonDataModel: dims, attribs, groups
import CommonDataModel: AbstractDataset, AbstractVariable,
    boundsParentVar, initboundsmap!,
    fillvalue, fill_and_missing_values,
    scale_factor, add_offset, time_origin, time_factor,
    CFtransformdata!,
    CFVariable, variable, cfvariable, defVar, load!,
    path, name, isopen, unlimited, dataset,
    groupname, groupnames, group, defGroup, Groups,
    varnames,
    dimnames, dim, defDim, Dimensions,
    attribnames, attrib, defAttrib, delAttrib, Attributes,
    varbyattrib, CFStdName, @CF_str, ancillaryvariables, filter, coord, bounds,
    MFDataset, MFCFVariable,
    DeferDataset, metadata, Resource,
    SubDataset, SubVariable,
    chunking, deflate, checksum, fillmode,
    iswritable, sync, CatArrays,
    SubDataset,
    @select, select, Near, coordinate_value, coordinate_names, split_by_and,
    chunking, deflate, checksum,
    maskingvalue


import DiskArrays
import DiskArrays: readblock!, writeblock!, eachchunk, haschunks

function __init__()
    NetCDF_jll.is_available() && init_certificate_authority()
end

const default_timeunits = "days since 1900-00-00 00:00:00"
const SymbolOrString = Union{Symbol, AbstractString}

include("types.jl")
include("errorhandling.jl")
include("lock.jl")
include("netcdf_c.jl")
include("dataset.jl")
include("attributes.jl")
include("dimensions.jl")
include("groupes.jl")
include("variable.jl")
include("cfvariable.jl")
include("defer.jl")
include("multifile.jl")
include("ncgen.jl")
include("precompile.jl")

export CatArrays
export CFTime
export daysinmonth, daysinyear, yearmonthday, yearmonth, monthday
export dayofyear, firstdayofyear
export DateTimeStandard, DateTimeJulian, DateTimeProlepticGregorian,
    DateTimeAllLeap, DateTimeNoLeap, DateTime360Day, AbstractCFDateTime

export coord
export bounds
export @CF_str

VERSION >= v"1.11.0-DEV.469" && eval(Meta.parse("public @select, select"))

end # module
