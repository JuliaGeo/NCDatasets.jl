using NCDatasets
using NCDatasets: nc_open, nc_close,NC_WRITE, NC_NOWRITE, nc_inq_varid,
    nc_get_var!,
    nc_put_var
using NCDatasets.NetCDF_jll: ncgen, ncdump
using Test


filename = tempname()

# Note issue
# https://github.com/Unidata/netcdf-c/issues/3407
# enum cloud_t cannot be byte but must be int here for NetCDF 4.10.0

write("compound_enum.cdl","""
netcdf weather_data {
types:
  int enum cloud_t {Clear = 0, Cumulonimbus = 1, Stratus = 2, Overcast = 3};

  compound obs_t {
    float temperature;
    int humidity;
    cloud_t sky_condition;  // Nested Enum
  };

dimensions:
  station = 4;

variables:
  obs_t weather_reports(station);
}
""")


run(`$(ncgen()) -o $filename compound_enum.cdl`)
#run(`$(ncdump())  $filename`)


@enum Cloud::Int32 begin
    Clear          = 0
    Cumulonimbus   = 1
    Stratus        = 2
    Overcast       = 3
end

struct Obs
    temperature::Float32
    humidity::Int32
    sky_condition::Cloud
end


data = [Obs(20 + i, 60 + i, reinterpret(Cloud,Int32(i % 4))) for i in 0:3]
data2 = similar(data)

# write NetCDF file

ncid = nc_open(filename,NC_WRITE)
varid = nc_inq_varid(ncid,"weather_reports")
nc_put_var(ncid,varid,data)
nc_close(ncid)

# read NetCDF file

ncid = nc_open(filename,NC_NOWRITE)
varid = nc_inq_varid(ncid,"weather_reports")
nc_get_var!(ncid,varid,data2)
nc_close(ncid)


@test data == data2
