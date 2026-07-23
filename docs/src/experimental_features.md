# Experimental features

Experimental features are feature than not have been thoroughly tested and these features are not considered by the semantic version.

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
For the MPI IO standard, collective IO means that all MPI processes execute all the same OI functions (calling for example [MPI\_File\_write\_at\_all](https://www.mpich.org/static/docs/v4.1/www3/MPI_File_write_at_all.html)). If this is not the case, then the access is independently (calling for example [MPI\_File\_write\_at](https://www.mpich.org/static/docs/v4.1/www3/MPI_File_write_at.html)).

Only the NetCDF 4 format can be currently used for parallel access. On Windows, the MPI interface is [currently unsupported](https://github.com/JuliaPackaging/Yggdrasil/issues/8523). Help from developers with access to Windows would be appreciated.

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

# enable collective access (:independent is the default)
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

# NetCDF compound types

NetCDF 4 allows the users to define their own type, in particular, compound types which correspond to Julia structures.
An array of such structures can be written to and loaded from a NetCDF file. For example:

```julia
fname = download("https://raw.githubusercontent.com/Unidata/netcdf-c/refs/tags/v4.8.1/dap4_test/nctestfiles/test_struct_array.nc")
ds = NCDataset(fname)

array = ds["s"][:,:]
typeof(array)
# output
# Matrix{c_t} (alias for Array{NCDatasets.ReconstructedTypes_123.c_t, 2})

struct MyCompoundType
    x::Int32
    y::Int32
end

NCDatasets.typemap!(ds,"c_t" => MyCompoundType)
array = ds["s"][:,:]
typeof(array)
# output
# Matrix{MyCompoundType} (alias for Array{MyCompoundType, 2})

```

It is preferable in fact that the user defines the compound type as a julia struct and register it using the `NCDatasets.typemap!`.
Users should not rely on the type name generated internally by `NCDatasets`. Note also that Julia treats two types as different even if they have
the same memory layout.
When defining these structures, avoid using the type `Int` as its size is platform-dependent. Vectors of fixed length can also be used in struct fields.
They should be declared as `NTuple`s (see
[Calling C and Fortran Code](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/#Struct-Type-Correspondences) for the manual).

Here is an example to write such a dataset:

```julia
n = 5
array2 = MyCompoundType.(1:n,n:-1:1)
fname = tempname()
ds = NCDataset(fname,"c")
defDim(ds,"dim",n)
ncv = defVar(ds,"data",MyCompoundType,("dim",); typename = "my_nc_compound_type")
ncv[:] = array2
close(ds)

# or more compactly:

NCDataset(fname,"c") do ds
    # the Julia type name is used by default in the netcdf file
    # dimension "dim" is created automatically
    ncv = defVar(ds,"data",array2,("dim",))
end
```

An important restriction is that the `struct` must be immutable and contain only immutable fields. The memory layout of a `mutable struct` is not compatible with the layout expected by the C library. To update a single field in a struct, the user has to recreate the structure. For example to update the field `x` of the the first element to 10:

```julia
array2[1] = MyCompoundType(10,array2[1].y)
```

For large structures, it might be beneficial to use [Accessors](https://github.com/JuliaObjects/Accessors.jl).

```julia
using Accessors
@set array2[1].x = 10
```

# NetCDF enum type

NetCDF enum types are implemented as Julia enum types. This example shows how to create a enum type and write as an vector of enums to a NetCDF file:

``` julia
@enum TestEnum::Int8 good=1 bad=2 ugly=3

data = [good, bad, good, ugly]
fname = tempname()
NCDataset(fname,"c") do ds
    # the Julia type name is used by default in the netcdf file
    # dimension "dim" is created automatically
    ncv = defVar(ds,"data",data,("dim",))
end

```

Loading the data:

``` julia
data2 = NCDataset(fname,"r") do ds
    # The julia type TestEnum must be internally reconstructed unless
    # it is provided via ds.typemap! (which is preferred)
    NCDatasets.typemap!(ds,"TestEnum" => TestEnum)
    # the Julia type name is used by default in the netcdf file
    # dimension "dim" is created automatically
    ds["data"][:]
end
```

The array of enums `data` can be converted to, for example, a `CategoricalArray` of strings using:

```julia
using CategoricalArrays
enum_dict = Dict(inst => string(inst) for inst in instances(eltype(data)))
ca = CategoricalArray([enum_dict[x] for x in data]; levels=collect(values(enum_dict)))
```
