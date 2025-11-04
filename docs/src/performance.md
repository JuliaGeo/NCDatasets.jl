# [Performance tips](@id performance_tips)

* Reading data from a file is not type-stable, because the type of the output of the read operation is dependent on the type defined in the NetCDF files and the value of various attribute (like `scale_factor`, `add_offset` and `units` for time conversion). All this information cannot be inferred from a static analysis of the source code. It is therefore recommended to use [type annotation](https://docs.julialang.org/en/v1/manual/types/index.html#Type-Declarations-1) if the resulting type of a read operation in known:

```julia
ds = NCDataset("file.nc")
nctemp = ds["temp"]
temp = nctemp[:,:] :: Array{Float32,2}

# heavy computation using temp
# ...
```

Alternatively, one can also use so-called [function barriers](https://docs.julialang.org/en/v1/manual/performance-tips/index.html#kernel-functions-1)
since the function `heavy_computation` will be specialized based on the type its input parameters.


```julia
function heavy_computation(temp)
# heavy computation using temp
# ...
end

ds = NCDataset("file.nc")
nctemp = ds["temp"]
temp = nctemp[:,:]
output = heavy_computation(temp)
```

Calling the barrier function with `nctemp` would also be type-stable.
Using the in-place `NCDatasets.load!` function (which is unexported, so it has to be prefixed with the module name) does also lead to type-stable code and allows to reuse a memory buffer:

```julia
ds = NCDataset("file.nc")

temp = zeros(Float32,10,20)
NCDatasets.load!(variable(ds,"temp"),temp,:,:)
```
