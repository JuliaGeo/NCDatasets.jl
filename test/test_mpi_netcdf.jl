using MPIPreferences
using MPI
using NCDatasets
import NCDatasets: NCDataset
using NCDatasets: nc_create, NC_NETCDF4, NC_CLOBBER, nc_close, check, libnetcdf, nc_def_dim, nc_def_var, nc_put_var1, check


function nc_create_par(path,cmode,mpi_comm::MPI.Comm,mpi_info::MPI.Info)
    ncidp = Ref{Cint}()
    check(ccall((:nc_create_par,libnetcdf),Cint,
                (Cstring,Cint,MPI.MPI_Comm,MPI.MPI_Info,Ptr{Cint}),
                path,cmode,mpi_comm,mpi_info,ncidp))

    return ncidp[]
end

function nc_open_par(path,omode,mpi_comm::MPI.Comm,mpi_info::MPI.Info)
    ncidp = Ref{Cint}()
    check(ccall((:nc_open_par,libnetcdf),Cint,
                (Cstring,Cint,MPI.MPI_Comm,MPI.MPI_Info,Ptr{Cint}),
                path,omode,mpi_comm,mpi_info,ncidp))

    return ncidp[]
end

function nc_var_par_access(ncid,varid,par_access)
    check(ccall((:nc_var_par_access,libnetcdf),Cint,
                (Cint,Cint,Cint),
                ncid,varid,par_access))
end


function NCDataset(mpi_comm::MPI.Comm,
                   filename::AbstractString,
                   mode::AbstractString = "r";
                   mpi_info = MPI.INFO_NULL,
                   format::Symbol = :netcdf4,
                   share::Bool = false,
                   diskless::Bool = false,
                   persist::Bool = false,
                   memory::Union{Vector{UInt8},Nothing} = nothing,
                   maskingvalue = missing,
                   attrib = [])

    cmode = NC_CLOBBER | NC_NETCDF4
    ncid = nc_create_par(filename,cmode,mpi_comm,mpi_info)
    iswritable = true
    isdefmode = Ref(false)

    ds = NCDataset(ncid,iswritable,isdefmode)
    return ds
end

mpiexec = realpath(joinpath(dirname(pathof(MPI)),"..","bin","mpiexecjl"))
#println("run with:\n  $mpiexec -n 4 julia test_mpi_netcdf.jl")

MPI.Init()

mpi_comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(mpi_comm)
csize = MPI.Comm_size(mpi_comm)


filename = "/tmp/foo.nc"
ds = NCDataset(mpi_comm,filename)

defDim(ds,"rank",csize)
defVar(ds,"var",Float64,("rank",))

ds["var"][rank+1] = rank
close(ds)
