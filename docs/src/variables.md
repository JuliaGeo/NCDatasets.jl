# Variables

Variables (like e.g. `CFVariable`) are the quantities contained within a NetCDF dataset. See the [Datasets](@ref) page on how to obtain them from a dataset.

Different type of arrays are involved when working with NCDatasets. For instance assume that `test.nc` is a file with a `Float32` variable called `variable`.

```julia
using NCDatasets
ds = NCDataset("test.nc")
ncvar_cf = ds["variable"]
```

The variable `ncvar_cf` has the type `CFVariable`. No data is actually loaded from disk, but you can query its size, number of dimensions, number elements, etc., using the functions `size`, `ndims`, `length` as if `ncvar_cf` was an ordinary Julia array.

To load the variable `ncvar_cf` in memory you can convert it into an array with:

```julia
data = Array(ncvar_cf)
# or
data = ncvar_cf |> Array
# or if ndims(ncvar_cf) == 2
data = ncvar_cf[:,:]
```

Since NCDatasets 0.13, the syntax `ncvar_cf[:]` flattens the array, and is not equivalent with the above (unless `ncvar_cf` is a vector).

You can only load sub-parts of it in memory via indexing each dimension:

```julia
ncvar_cf[1:5, 10:20]
```

A scalar variable can be loaded using `[]`, for example:

```julia
using NCDatasets
NCDataset("test_scalar.nc","c") do ds
    # the list of dimension names is simple `()` as a scalar does not have dimensions
    defVar(ds,"scalar",42,())
end

ds = NCDataset("test_scalar.nc")
value = ds["scalar"][] # 42
```

To load all a variable in a NetCDF file ignoring attributes like `scale_factor`, `add_offset`, `_FillValue` and time units one can use the property `var` or the function `variable` for example:

```julia
using NCDatasets
using Dates
data = [DateTime(2000,1,1), DateTime(2000,1,2)]
NCDataset("test_file.nc","c") do ds
    defVar(ds,"time",data,("time",), attrib = Dict(
               "units" => "days since 2000-01-01"))
end;

ds = NCDataset("test_file.nc")
ncvar = ds["time"].var
# or
ncvar = variable(ds,"time")
data = ncvar[:] # here [0., 1.]
```

The variable `ncvar` can be indexed in the same way as `ncvar_cf` explained above.


The following functions are convenient for working with variables:

```@docs
Base.size(v::NCDatasets.CFVariable)
dimnames
dimsize
name
renameVar
NCDataset(var::NCDatasets.CFVariable)
nomissing
fillvalue
```

```@docs
loadragged
NCDatasets.load!
```
## Creating a variable

```@docs
defVar
```

## Storage parameter of a variable

```@docs
chunking
deflate
checksum
```


## Coordinate variables and cell boundaries

```@docs
coord
bounds
```
