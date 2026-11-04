
#using Pkg
#Pkg.activate("ncd",shared=true)


using NCDatasets
using Test

NCDatasets.register_plugins!()

zstd_id = 32015
level = 3
data = zeros(Int8,1_000_000);

fname = tempname()
ds = NCDataset(fname,"c");
ncid = ds.ncid
@test NCDatasets.nc_inq_filter_avail(ncid,zstd_id)

defDim(ds,"dim",length(data));
v = defVar(ds,"var-zstd",Int8,("dim",))
NCDatasets.zstandard(v.var,level)
@test NCDatasets.zstandard(v.var) == (true,level)

v[:] .= data
close(ds)


@test stat(fname).size < length(data)
