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

