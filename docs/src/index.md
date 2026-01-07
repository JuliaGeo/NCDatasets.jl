# NCDatasets.jl

Documentation for [NCDatasets.jl](https://github.com/JuliaGeo/NCDatasets.jl), a Julia package for loading and writing NetCDF ([Network Common Data Form](https://www.unidata.ucar.edu/software/netcdf/)) files.
NCDatasets.jl implements the for the NetCDF format the interface defined
in [CommonDataModel.jl](https://github.com/JuliaGeo/CommonDataModel.jl).
All functions defined by CommonDataModel.jl are also available for NetCDF data, including:
* virtually concatenating multiple files along a given dimension
* create a virtual subset (`view`) by indices or by values of coordinate variables (`CommonDataModel.select`, `CommonDataModel.@select`)
* group, map and reduce (with `mean`, standard deviation `std`, ...) a variable (`CommonDataModel.groupby`, `CommonDataModel.@groupby`) and rolling reductions like running means `CommonDataModel.rolling`).

## Installation

Inside the Julia shell, you can download and install NCDatasets using the following commands:

```julia
using Pkg
Pkg.add("NCDatasets")
```

Or by typing `]add NCDatasets` using the package manager REPL-mode.

### Latest development version

If you want to try the latest development version, again go into package manager mode and simply type

```julia
using Pkg
Pkg.add(PackageSpec(name="NCDatasets", rev="main"))
```

## Contents

To get started quickly see the [Quick start](@ref) section. Otherwise see the following pages for details:

* [Datasets](@ref) : reading/writing NetCDF datasets (including NetCDF groups) and examining their contents.
* [Dimensions](@ref) : accessing/creating NetCDF dimensions
* [Variables](@ref) : accessing/examining the variables (or dimensions) stored within a NetCDF dataset.
* [Attributes](@ref) : accessing/creating NetCDF attributes
* See [Fill values and missing values](@ref), [Performance tips](@ref performance_tips), [Other features](@ref) and [Known issues](@ref) for more information.

## Quick start

This is a quick start guide that outlines basic loading, reading, etc. usage.
For more details please see the individual pages of the documentation.


* [Explore the content of a netCDF file](@ref)
* [Load a netCDF file](@ref)
* [Create a netCDF file](@ref)
* [Edit an existing netCDF file](@ref)
* [Create a netCDF file using the metadata of an existing netCDF file as template](@ref)
* [Get one or several variables by specifying the value of an attribute](@ref)
* [Load a file with unknown structure](@ref)

### Explore the content of a netCDF file

Before reading the data from a netCDF file, it is often useful to explore the list of variables and attributes defined in it.

For interactive use, the following commands (without ending semicolon) display the content of the file similarly to `ncdump -h file.nc`:

```julia
using NCDatasets
ds = NCDataset("file.nc")
```

which produces a listing like:

```
NCDataset: file.nc
Group: /

Dimensions
   time = 115

Variables
  time   (115)
    Datatype:    Float64
    Dimensions:  time
    Attributes:
     calendar             = gregorian
     standard_name        = time
     units                = days since 1950-01-01 00:00:00
[...]
```

This creates the central structure of NCDatasets.jl, `NCDataset`, which represents the contents of the netCDF file (without immediately loading everything in memory).

The following displays the information just for the variable `varname`:

```julia
ds["varname"]
```

To get a list of global attributes, you can use:

```julia
ds.attrib
```



### Load a netCDF file

Loading a variable with known structure can be achieved by accessing the variables and attributes directly by their name.

```julia
# The mode "r" stands for read-only. The mode "r" is the default mode and the parameter can be omitted.
ds = NCDataset("/tmp/test.nc","r")
v = ds["temperature"]

# load a subset
subdata = v[10:30,30:5:end]

# load all data
data = v[:,:]

# load all data ignoring attributes like scale_factor, add_offset, _FillValue and time units
data2 = v.var[:,:]


# load an attribute
unit = v.attrib["units"]
close(ds)
```

In the example above, the subset can also be loaded with:

```julia
subdata = NCDataset("/tmp/test.nc")["temperature"][10:30,30:5:end]
```

This might be useful in an interactive session. However, the file `test.nc` is not closed, which can be a problem if you open many files. On Linux the number of opened files is often limited to 1024 (soft limit). If you write to a file, you should also always close the file to make sure that the data is properly written to the disk.
(open files will get closed eventually when the dataset variable is finalized by julia's garbage collector).

An alternative way to ensure the file has been closed is to use a `do` block: the file will be closed automatically when leaving the block.

```julia
data = NCDataset(filename,"r") do ds
    ds["temperature"][:,:]
end # ds is closed
```

In general, names (variable names, dimension names, attributes name and group names) can either by `"strings"` or `:symbols`.

```julia
data_units = ds[:temperature].attrib[:units]
# is the same as
data_units = ds["temperature"].attrib["units"]
```

### Create a netCDF file

The following gives an example of how to create a netCDF file by defining dimensions, variables and attributes.

```julia
using NCDatasets
# This creates a new NetCDF file /tmp/test.nc.
# The mode "c" stands for creating a new file (clobber)
ds = NCDataset("/tmp/test.nc","c")

# Define the dimension "lon" and "lat" with the size 100 and 110 resp.
defDim(ds,"lon",100)
defDim(ds,"lat",110)

# Define a global attribute
ds.attrib["title"] = "this is a test file"

# Define the variables temperature
v = defVar(ds,"temperature",Float32,("lon","lat"))

# Generate some example data
data = [Float32(i+j) for i = 1:100, j = 1:110]

# write a single column
v[:,1] = data[:,1]

# write a the complete data set
v[:,:] = data

# write attributes
v.attrib["units"] = "degree Celsius"
v.attrib["comments"] = "this is a string attribute with Unicode Ω ∈ ∑ ∫ f(x) dx"

close(ds)
```

An equivalent way to create the previous netCDF would be the following code:

```julia
using NCDatasets
using DataStructures
data = [Float32(i+j) for i = 1:100, j = 1:110]

NCDataset("/tmp/test2.nc","c",attrib = OrderedDict("title" => "this is a test file")) do ds
    # Define the variable temperature. The dimension "lon" and "lat" with the
    # size 100 and 110 resp are implicitly created
    defVar(ds,"temperature",data,("lon","lat"), attrib = OrderedDict(
           "units" => "degree Celsius",
           "comments" => "this is a string attribute with Unicode Ω ∈ ∑ ∫ f(x) dx"
    ))
end
```

### Edit an existing netCDF file

When you need to modify the variables or the attributes of a netCDF, you have
to open it with the `"a"` option. Here, for instance, we add a global attribute *creator* to the
file created in the previous step.

```julia
ds = NCDataset("/tmp/test.nc","a")
ds.attrib["creator"] = "your name"
close(ds);
```

### Create a netCDF file using the metadata of an existing netCDF file as template

The utility function [`ncgen`](https://juliageo.org/NCDatasets.jl/stable/#NCDatasets.ncgen)
generates the Julia code that would produce a netCDF file with the same metadata as a template netCDF file.
It is thus similar to the [command line tool `ncgen`](https://www.unidata.ucar.edu/software/netcdf/netcdf/ncgen.html)
which can generate C or Fortran code from the output of [`ncdump`](https://www.unidata.ucar.edu/software/netcdf/netcdf/ncdump.html).

```julia
using Downloads: download
# download an example file
ncfile = download("https://www.unidata.ucar.edu/software/netcdf/examples/sresa1b_ncar_ccsm3-example.nc")
# generate Julia code
ncgen(ncfile)
```

The produces the Julia code (only the beginning of the code is shown):

```julia
ds = NCDataset("filename.nc","c")
# Dimensions

ds.dim["lat"] = 128;
ds.dim["lon"] = 256;
ds.dim["bnds"] = 2;
ds.dim["plev"] = 17;
ds.dim["time"] = 1;

# Declare variables

ncarea = defVar(ds,"area", Float32, ("lon", "lat"))
ncarea.attrib["long_name"] = "Surface area";
ncarea.attrib["units"] = "meter2";
# ...
```

### Get one or several variables by specifying the value of an attribute

The variable names are not always standardized. For example, the longitude can
be named: `lon`, `LON`, `longitude`, `łøñgitüdè`, ...

The solution implemented in the function `varbyattrib` consists in searching for the
variables that have specified value for a given attribute.

```julia
nclon = varbyattrib(ds, standard_name = "longitude");
```
will return the list of variables of the dataset `ds` that have "longitude"
as standard name. To directly load the data of the first variable with the
attribute `standard_name` equal to `"longitude"` one can do the following:

```julia
data = varbyattrib(ds, standard_name = "longitude")[1][:]
```

As looking-up a variable by standard name is quite common, one can also use the
`@CF_str` macro and index the dataset using a string prefixed by `CF`.

```julia
using NCDatasets: @CF_str
ds[CF"longitude"]
```

If multiple variables share the same standard name, such statements `ds[CF"longitude"]` are ambiguous and an error is returned.
This is typically the case for e.g. ocean models like ROMS where different variables (u, v and w velocity) are defined on different staggered grids (i.e. shifted by a half grid-cell from each other).
To disambiguate, one can first index the dataset `ds` with main data variable (e.g. vertical velocity) and then again extract the longitude associated to the data variable.

```julia
ds[CF"upward_sea_water_velocity"][CF"longitude"]
```

Such statement is no longer ambiguous as from the dimension names it is clear which longitude has to be accessed.

### Load a file with unknown structure

If the structure of the netCDF file is not known before-hand, the program must check if a variable or attribute exists (with the `haskey` function) before loading it or alternatively place the loading in a `try`-`catch` block.
It is also possible to iterate over all variables or attributes (global attributes or variable attributes) in the same syntax as iterating over a dictionary. However, unlike Julia dictionaries, the order of the attributes and variables is preserved and presented as they are stored in the netCDF file.


```julia
# Open a file as read-only
ds = NCDataset("/tmp/test.nc","r")

# check if a file has a variable with a given name
if haskey(ds,"temperature")
    println("The file has a variable 'temperature'")
end

# get a list of all variable names
@show keys(ds)

# iterate over all variables
for (varname,var) in ds
    @show (varname,size(var))
end

# query size of a variable (without loading it)
v = ds["temperature"]
@show size(v)

# similar for global and variable attributes

if haskey(ds.attrib,"title")
    println("The file has the global attribute 'title'")
end

# get an list of all attribute names
@show keys(ds.attrib)

# iterate over all attributes
for (attname,attval) in ds.attrib
    @show (attname,attval)
end

# get the attribute "units" of the variable v
# but return the default value (here "adimensional")
# if the attribute does not exists

units = get(v,"units","adimensional")
close(ds)
```

## API and semantic versioning

The package aims to following [semantic versioning](https://semver.org/).
[As in julia](https://docs.julialang.org/en/v1/manual/faq/#How-does-Julia-define-its-public-API), what is considered as public API and covered by semantic versioning is what documented and not marked as experimental or internal.
