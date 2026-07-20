using NCDatasets
using NCDatasets: nc_open, nc_close,NC_WRITE, NC_NOWRITE, nc_inq_varid,
    nc_get_var!,
    nc_put_var
using Test


filename = tempname()

# Note issue
# https://github.com/Unidata/netcdf-c/issues/3407
# enum cloud_t cannot be byte but must be int here for NetCDF 4.10.0

@enum Cloud::Int32 begin
    Clear          = 0
    Cumulonimbus   = 1
    Stratus        = 2
    Overcast       = 3
end

struct ObsWithEnum
    temperature::Float32
    humidity::Int32
    sky_condition::Cloud
end


data = [ObsWithEnum(20 + i, 60 + i, reinterpret(Cloud,Int32(i % 4))) for i in 0:3]

fname = tempname()
ds = NCDataset(fname,"c");
NCDatasets.defType(ds,"cloud_t",Cloud);
NCDatasets.defType(ds,"obs_t",ObsWithEnum);
defVar(ds,"weather_reports",data,("station",))
close(ds)


ds = NCDataset(fname,"r");
NCDatasets.usertype!(ds,"cloud_t",Cloud);
NCDatasets.usertype!(ds,"obs_t",ObsWithEnum);
data2 = ds["weather_reports"][:]
@test data == data2

#=
run(`ncdump -h $fname`)
=#
