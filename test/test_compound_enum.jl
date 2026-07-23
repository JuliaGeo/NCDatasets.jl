using NCDatasets
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


# reconstructed type

ds = NCDataset(fname,"r");
data2 = ds["weather_reports"][:]

@test getproperty.(data,:temperature) == getproperty.(data2,:temperature)
@test Integer.(getproperty.(data,:sky_condition)) == Integer.(getproperty.(data2,:sky_condition))
@test data == reinterpret(ObsWithEnum,data2)

#=
run(`ncdump -h $fname`)
=#

# copy reconstructed variable

fname2 = tempname(suffix=".nc")
ds = NCDataset(fname2,"c");
defVar(ds,"weather_reports",data2,("station",))
close(ds)

#=
run(`ncdump -h $fname2`)
=#
