# Datasets

This page is about loading/writing, examining and operating directly on entire NetCDF datasets. For functions regarding the variables stored in them, see the [Variables](@ref) page.

Both variables and datasets share the functionality of the [Attributes](@ref) section.

```@docs
NCDataset
```

Useful functions that operate on datasets are:

```@docs
getindex(ds::NCDataset,varname::AbstractString)
variable
cfvariable
sync
close
NCDatasets.path
ncgen
varbyattrib
write
```

Notice that DateTime-structures from [CFTime](http://juliageo.org/CFTime.jl/stable/) are used to represent time for non-standard calendars.
Otherwise, we attempt to use standard structures from the Julia standard library `Dates`.


## Groups

A NetCDF group is a dataset (with variables, attributes, dimensions and sub-groups) and
can be arbitrarily nested.
A group is created with `defGroup` and accessed via the `group` property of
a `NCDataset`.

```julia
# create the variable "temperature" inside the group "forecast"
ds = NCDataset("results.nc", "c");
ds_forecast = defGroup(ds,"forecast")
defVar(ds_forecast,"temperature",randn(10,11,12),("lon","lat","time"))

# load the variable "temperature" inside the group "forecast"
forecast_temp = ds.group["forecast"]["temperature"][:,:,:]
close(ds)
```

```@docs
defGroup
getindex(g::NCDatasets.Groups,groupname)
keys(g::NCDatasets.Groups)
```

## Common methods

One can iterate over a dataset, attribute list, dimensions and NetCDF groups.

```julia
for (varname,var) in ds
    # all variables
    @show (varname,size(var))
end

for (attribname,attrib) in ds.attrib
    # all attributes
    @show (attribname,attrib)
end

for (groupname,group) in ds.groups
    # all groups
    @show (groupname,group)
end
```
