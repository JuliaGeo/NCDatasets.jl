module NCDatasetsMPIExt
using MPI
using NCDatasets
using NCDatasets:
    NC_COLLECTIVE,
    NC_FORMAT_NETCDF4,
    NC_FORMAT_NETCDF4_CLASSIC,
    NC_GLOBAL,
    NC_INDEPENDENT,
    Variable,
    _dataset_ncmode,
    check,
    dataset,
    libnetcdf,
    nc_inq_format

import NCDatasets:
    NCDataset,
    paraccess

function nc_create_par(path,cmode::Integer,mpi_comm,mpi_info)
    ncidp = Ref(Cint(0))
    check(ccall((:nc_create_par,libnetcdf),Cint,
                (Cstring,Cint,MPI.MPI_Comm,MPI.MPI_Info,Ref{Cint}),
                path,cmode,mpi_comm,mpi_info,ncidp))

    return ncidp[]
end

function nc_open_par(path,cmode::Integer,mpi_comm,mpi_info)
    ncidp = Ref(Cint(0))
    check(ccall((:nc_open_par,libnetcdf),Cint,
                (Cstring,Cint,MPI.MPI_Comm,MPI.MPI_Info,Ref{Cint}),
                path,cmode,mpi_comm,mpi_info,ncidp))

    return ncidp[]
end

function nc_var_par_access(ncid,varid,par_access)
    check(ccall((:nc_var_par_access,libnetcdf),Cint,
                (Cint,Cint,Cint),
                ncid,varid,par_access))
end

function parallel_access_mode(par_access::Symbol)
    if par_access == :collective
        return NC_COLLECTIVE
    elseif par_access == :independent
        return NC_INDEPENDENT
    else
        error("Unknown parallel access mode $par_access. Only :collective and :independent are supported.")
    end
end

"""
    NCDatasets.paraccess(ncv::Variable,par_access::Symbol)
    NCDatasets.paraccess(ds::NCDataset,par_access::Symbol)

Change the parallel access mode of the variable `ncv` or all variables of the dataset `ds` for writing or reading data. `par_access` is either `:collective` or `:independent`. `NCDatasets.paraccess` will raise an error if `MPI` is not loaded.

More information is available in the [NetCDF documentation](https://web.archive.org/web/20240414204638/https://docs.unidata.ucar.edu/netcdf-c/current/parallel_io.html).
"""
function paraccess(ncv::Variable,par_access::Symbol)
    ds = dataset(ncv)
    ncid = ds.ncid
    varid = ncv.varid

    if nc_inq_format(ncid) in (NC_FORMAT_NETCDF4, NC_FORMAT_NETCDF4_CLASSIC)
        nc_var_par_access(ncid,varid,parallel_access_mode(par_access))
    else
        error("The netCDF 3 and 5 formats do not allow different access methods per variable. You need to call this function for the whole data set: NCDatasets.paraccess(ds,$par_access)")
    end
end

# set collective or independent IO globally (for all variables)
function paraccess(ds::NCDataset,par_access::Symbol)
    if nc_inq_format(ds.ncid) in (NC_FORMAT_NETCDF4, NC_FORMAT_NETCDF4_CLASSIC)
        for (varname,ncv) in ds
            paraccess(ncv.var,par_access)
        end
    else
        # only for PnetCDF
        nc_var_par_access(ds.ncid,NC_GLOBAL,parallel_access_mode(par_access))
    end
end

"""
    ds = NCDataset(comm::MPI.Comm,filename::AbstractString,
                   mode::AbstractString = "r";
                   info = MPI.INFO_NULL,
                   maskingvalue = missing,
                   attrib = [])

Open or create a netCDF file `filename` for parallel IO using the MPI
communicator `comm`. `info` is a
[MPI info object](https://juliaparallel.org/MPI.jl/stable/reference/advanced/#Info-objects)
containing IO hints or `MPI.INFO_NULL` (default). The `mode` is either `"r"` (default) to open an
existing netCDF file in read-only mode, `"c"`  to create a new netCDF file  (an
existing file with the same name will be overwritten) or `"a"` to append to an
existing file.
"""
function NCDataset(comm::MPI.Comm,filename::AbstractString,
                   mode::AbstractString = "r";
                   info = MPI.INFO_NULL,
                   format::Symbol = :netcdf4,
                   share::Bool = false,
                   diskless::Bool = false,
                   persist::Bool = false,
                   maskingvalue = missing,
                   attrib = [])

    ncid = -1
    isdefmode = fill(false)
    ncmode = _dataset_ncmode(filename,mode,format;
                             diskless = diskless,
                             persist = persist,
                             share = share)

    @debug "ncmode: $ncmode"

    if (mode == "r") || (mode == "a")
        ncid = nc_open_par(filename,ncmode,comm,info)
    elseif mode == "c"
        ncid = nc_create_par(filename,ncmode,comm,info)
        isdefmode[] = true
    end

    iswritable = mode != "r"
    ds = NCDataset(
        ncid,iswritable,isdefmode,
        maskingvalue = maskingvalue)

    # set global attributes
    for (attname,attval) in attrib
        ds.attrib[attname] = attval
    end

    return ds
end

end
