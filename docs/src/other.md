# Other features

## Multi-file support

Multiple files can also be aggregated over a given dimension (or the record dimension). In this example, 3 sea surface temperature fields from the
1992-01-01 to 1992-01-03 are aggregated using the OPeNDAP service from PODAAC.

```julia
using NCDatasets, Printf, Dates

function url(dt)
  doy = @sprintf("%03d",Dates.dayofyear(dt))
  y = @sprintf("%04d",Dates.year(dt))
  yyyymmdd = Dates.format(dt,"yyyymmdd")
  return "https://podaac-opendap.jpl.nasa.gov:443/opendap/allData/ghrsst/data/GDS2/L4/GLOB/CMC/CMC0.2deg/v2/$y/$doy/$(yyyymmdd)120000-CMC-L4_GHRSST-SSTfnd-CMC0.2deg-GLOB-v02.0-fv02.0.nc"
end

ds = NCDataset(url.(DateTime(1992,1,1):Dates.Day(1):DateTime(1992,1,3)),aggdim = "time");
SST2 = ds["analysed_sst"][:,:,:];
close(ds)
```

If there is a network or server issue, you will see an error message like `NetCDF: I/O failure`.

## CF Standard Names

The CF Conventions do not define how the different NetCDF variables are named, but the meaning of a variable is defined by the [`standard_name`](https://cfconventions.org/standard-names.html) attribute.

```jldoctest mylabel
using NCDatasets, DataStructures
ds = NCDataset(tempname(),"c")

nclon = defVar(ds,"lon", 1:10, ("lon",),attrib = OrderedDict(
    "standard_name"             => "longitude",
))
nclat = defVar(ds,"lat", 1:11, ("lat",),attrib = OrderedDict(
    "standard_name"             => "latitude",
))
ncvar = defVar(ds,"bat", zeros(10,11), ("lon", "lat"), attrib = OrderedDict(
    "standard_name"             => "height",
))

ncbat = ds[CF"height"]
# the same as
# ncbat = varbyattrib(ds,standard_name = "height")[1]

name(ncbat)
# output
"bat"
```

If there are multiple variables with the `standard_name` equal to `height`, an error is returned because it is ambiguous which variable should be accessed.

All variables whose dimensions are also dimensions of `ncbat` are considered as related and can also be accessed by sub-setting `ncbat` with their variable names
of CF Standard name:

```jldoctest mylabel
nclon_of_bat = ncbat[CF"longitude"]
# same as
# nclon_of_bat = ncbat["lon"]
name(nclon_of_bat)
# output
"lon"
```

The previous call to `ncbat[CF"longitude"]` would also worked if there are multiple variables with a standard name `longitude` defined in a dataset as long as they have different dimension names (which is commonly the case for model output on staggered grid such as [Regional Ocean Modeling System](https://www.myroms.org/)).

## Views

In Julia, a [view of an array](https://docs.julialang.org/en/v1/base/arrays/#Views-(SubArrays-and-other-view-types)) is a subset of an array but whose elements still point to the original parent array. If one modifies an element of a view, the corresponding element in the parent array is modified too:

```jldoctest example_view_julia
A = zeros(4,4)
subset = @view A[2:3,2:4]
# or
# subset = view(A,2:3,2:4)

subset[1,1] = 2
A[2,2]
# output
2.0
```

Views do not use copy of the array. The parent array and the indices of the view are obtained via the function [`parent`](https://docs.julialang.org/en/v1/base/arrays/#Base.parent) and [`parentindices`](https://docs.julialang.org/en/v1/base/arrays/#Base.parentindices).

```jldoctest example_view_julia
parent(subset) == A
# true, as both arrays are the same

parentindices(subset)
# output
(2:3, 2:4)
```

In NCDatasets, variables can also be sliced as a view:


```jldoctest example_view_ncdatasets
using NCDatasets, DataStructures
ds = NCDataset(tempname(),"c")

nclon = defVar(ds,"lon", 1:10, ("lon",))
nclat = defVar(ds,"lat", 1:11, ("lat",))
ncvar = defVar(ds,"bat", zeros(10,11), ("lon", "lat"), attrib = OrderedDict(
    "standard_name"             => "height",
))

ncvar_subset = @view ncvar[2:4,2:3]
# or
# ncvar_subset = view(ncvar,2:4,2:3)

ncvar_subset[1,1] = 2
# ncvar[2,2] is now 2

ncvar_subset.attrib["standard_name"]

# output
"height"
```

This is useful for example when even the sliced array is too large to be loaded in RAM or when all attributes need to be preserved for the sliced array.

The variables `lon` and `lat` are related to `bat` because all dimensions of the variables `lon` and `lat` are also dimensions of `bat` (which is commonly the case for coordinate variables). Such related variables can be retrieved by indexing the NetCDF variables with the name of the corresponding variable:

```jldoctest example_view_ncdatasets
lon_subset = ncvar_subset["lon"]
lon_subset[:] == [2, 3, 4]
# output
true
```

A view of a NetCDF variable also implements the function `parent` and `parentindices` with the same meaning as for julia `Array`s.

A whole dataset can also be sliced using a `view(ds, dim1=range1, dim2=range2...)`. For example:

```jldoctest example_view_ncdatasets
ds_subset = view(ds, lon = 2:3, lat = 2:4)
# or
# ds_subset = @view ds[lon = 2:3, lat = 2:4]
ds_subset.dim["lon"]

# output
2
```

Such sliced datasets can for example be saved into a new NetCDF file using `write`:

```julia
write("slice.nc",ds_subset)
```

Any dimension not mentioned in the `@view` call is not sliced.
While `@view` produces a slice based on indices, the `NCDatasets.@select` macro produces a slice (of an NetCDF variable or dataset)
based on the values of other related variables (typically coordinates).

## Data selection based on values

```@docs
NCDatasets.@select
```



## Fill values and missing values

In the NetCDF [CF conventions](https://cfconventions.org/Data/cf-conventions/cf-conventions-1.11/cf-conventions.html#missing-data) there are the attributes `_FillValue` (single scalar)  and `missing_value` (single scalar or possibly a vector with multiple missing values). Value in the netCDF file matching, these attributes are replaced by the [`Missing` type](https://docs.julialang.org/en/v1/manual/missing/) in Julia per default. However, for some applications, it is more convenient to use another special value like the special floating point number `NaN`.

For example, this is a netCDF file where the variable `var` contains a `missing` which is automatically replaced by the fill value 9999.

```julia
using NCDatasets
data = [1. 2. 3.; missing 20. 30.]
ds = NCDataset("example.nc","c")
defVar(ds,"var",data,("lon","lat"),fillvalue = 9999.)
```

The raw data as stored in the NetCDF file is available using the property `.var`:

```julia
ds["var"].var[:,:]
# 2×3 Matrix{Float64}:
#     1.0   2.0   3.0
#  9999.0  20.0  30.0
```

Per default, the fill value is replaced by `missing` when indexing `ds["var"]`:

```julia
ds["var"][:,:]
# 2×3 Matrix{Union{Missing, Float64}}:
# 1.0        2.0   3.0
#  missing  20.0  30.0
```

The function `nomissing` allows to replace all missing value with a different value like `NaN`:

```julia
var_nan = nomissing(ds["var"][:,:],NaN)
# 2×3 Matrix{Float64}:
#   1.0   2.0   3.0
#  NaN    20.0  30.0
close(ds)
```

Such substitution can also be made more automatic using the experimental parameter `maskingvalue` that can be user per variable:


```julia
ds = NCDataset("example.nc","r")
ncvar_nan = cfvariable(ds,"var",maskingvalue = NaN)
ncvar_nan[:,:]
# 2×3 Matrix{Float64}:
#   1.0   2.0   3.0
# NaN    20.0  30.0
close(ds)
```

Or per data-set:

```julia
ds = NCDataset("example.nc","r", maskingvalue = NaN)
ds["var"][:,:]
# 2×3 Matrix{Float64}:
#   1.0   2.0   3.0
# NaN    20.0  30.0
close(ds)
```

Note, choosing the `maskingvalue` affects the element type of the NetCDF variable using julia type promotion rules, in particular note that following vector:


```julia
[1, NaN]
# 2-element Vector{Float64}:
#    1.0
#  NaN
```

is a vector with the element type `Float64` and not `Union{Float64,Int}`. All integers
are thus promoted to floating point number as `NaN` is a `Float64`.
Since NaN is considered as a `Float64` in Julia, we have also a promotion to `Float64` in such cases:

```julia
[1f0, NaN]
# 2-element Vector{Float64}:
#   1.0
# NaN
```

where `1f0` is the `Float32` number 1. Consider to use `NaN32` to avoid this promotion (which is automatically converted to 64-bit NaN for a `Float64` array):

```julia
using NCDatasets
data32 = [1f0 2f0 3f0; missing 20f0 30f0]
data64 = [1. 2. 3.; missing 20. 30.]
ds = NCDataset("example_float32_64.nc","c")
defVar(ds,"var32",data32,("lon","lat"),fillvalue = 9999f0)
defVar(ds,"var64",data64,("lon","lat"),fillvalue = 9999.)
close(ds)

ds = NCDataset("example_float32_64.nc","r", maskingvalue = NaN32)
ds["var32"][:,:]
# 2×3 Matrix{Float32}:
#   1.0   2.0   3.0
# NaN    20.0  30.0

ds["var64"][:,:]
# 2×3 Matrix{Float64}:
#   1.0   2.0   3.0
# NaN    20.0  30.0
```

Promoting an integer to a floating point number can lead to loss of precision. These are the smallest integers that cannot be represented as 32 and 64-bit floating numbers:

```julia
Float32(16_777_217) == 16_777_217 # false
Float64(9_007_199_254_740_993) == 9_007_199_254_740_993 # false
```

`NaN` should not be used for an array of dates, character or strings as it will result in an array with the element type `Any` following julia's promotion rules.
The use of `missing` as fill value, is thus preferable in the general case.


## Experimental functions

```@docs
NCDatasets.ancillaryvariables
NCDatasets.filter
```


## Experimental MPI support

Experimental MPI support is available as a package extension. It is important to load `MPI` in addition to `NCDatasets` to enable this package extension.
All metadata operators (creating dimensions, variables, attributes, groups or types) must be done *collectively*.
Reading and writing data of netCDF variables can be done *independently* (default) or *collectively*. If a variable (or whole dataset) is marked for *collectively* data access, the underlying HDF5 library can enable additional optimization.
More information is available in the [NetCDF documentation](https://web.archive.org/web/20240414204638/https://docs.unidata.ucar.edu/netcdf-c/current/parallel_io.html).

Only the NetCDF 4 format can be currently used for parallel access. On Windows, the MPI interface is [currently unsupported](https://github.com/JuliaPackaging/Yggdrasil/issues/8523). Help from developpers with access to Windows would be appreciated.

```julia
using MPI
using NCDatasets

MPI.Init()

mpi_comm = MPI.COMM_WORLD
mpi_comm_size = MPI.Comm_size(mpi_comm)
mpi_rank = MPI.Comm_rank(mpi_comm)

# The file needs to be the same for all processes
filename = "file.nc"

# index based on MPI rank
i = mpi_rank + 1

# create the netCDF file
ds = NCDataset(mpi_comm,filename,"c")

# define the dimensions
defDim(ds,"lon",10)
defDim(ds,"lat",mpi_comm_size)
ncv = defVar(ds,"temp",Int32,("lon","lat"))

# enable colletive access (:independent is the default)
NCDatasets.paraccess(ncv.var,:collective)

ncv[:,i] .= mpi_rank

ncv.attrib["units"] = "degree Celsius"
ds.attrib["comment"] = "MPI test"
close(ds)
```


```@docs
NCDataset(comm::MPI.Comm,filename::AbstractString,mode::AbstractString)
NCDatasets.paraccess
```
