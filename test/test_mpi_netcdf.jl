using Test
using MPIPreferences
using MPI
using NCDatasets
import NCDatasets: NCDataset
using NCDatasets: nc_create, NC_NETCDF4, NC_CLOBBER, nc_close, check, libnetcdf, nc_def_dim, nc_def_var, nc_put_var1, check, NC_NOWRITE

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
                   maskingvalue = missing,
                   attrib = [])

    isdefmode = Ref(false)

    ncmode =
        if mode == "r"
            NC_NOWRITE
        elseif mode == "a"
            NC_WRITE
        elseif mode == "c"
            NC_CLOBBER
        else
            throw(NetCDFError(-1, "Unsupported mode '$(mode)' for filename '$(filename)'"))
        end


    @debug "ncmode: $ncmode"

    isdefmode = Ref(false)
    if (mode == "r") || (mode == "a")
        ncid = nc_open_par(filename,ncmode,mpi_comm,mpi_info)
    elseif mode == "c"
        if format == :netcdf5_64bit_data
            ncmode = ncmode | NC_64BIT_DATA
        elseif format == :netcdf3_64bit_offset
            ncmode = ncmode | NC_64BIT_OFFSET
        elseif format == :netcdf4_classic
            ncmode = ncmode | NC_NETCDF4 | NC_CLASSIC_MODEL
        elseif format == :netcdf4
            ncmode = ncmode | NC_NETCDF4
        elseif format == :netcdf3_classic
            # do nothing
        else
            throw(NetCDFError(-1, "Unkown format '$(format)' for filename '$(filename)'"))
        end

        ncid = nc_create_par(filename,ncmode,mpi_comm,mpi_info)
        isdefmode[] = true
    end

    iswritable = mode != "r"

#    ds = NCDataset(
#        ncid,iswritable,isdefmode,
#        maskingvalue = maskingvalue)
    ds = NCDataset(ncid,iswritable,isdefmode)

    # set global attributes
    for (attname,attval) in attrib
        ds.attrib[attname] = attval
    end

    return ds
end

mpiexec = realpath(joinpath(dirname(pathof(MPI)),"..","bin","mpiexecjl"))
#println("run with:\n  $mpiexec -n 4 julia test_mpi_netcdf.jl")

MPI.Init()

mpi_comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(mpi_comm)
csize = MPI.Comm_size(mpi_comm)


filename = "/tmp/foo.nc"
ds = NCDataset(mpi_comm,filename,"c")

defDim(ds,"rank",csize)
defVar(ds,"var",Float64,("rank",))

ds["var"][rank+1] = rank
close(ds)


# read
ds = NCDataset(mpi_comm,filename)

@test ds["var"][rank+1] == rank
close(ds)

