using Test
using NCDatasets

module Clouds
@enum cloud_class_t::Int8 begin
    Clear = 0
    Cumulonimbus = 1
    Stratus = 2
    Stratocumulus = 3
    Cumulus = 4
    Altostratus = 5
    Nimbostratus = 6
    Altocumulus = 7
    Cirrostratus = 8
    Cirrocumulus = 9
    Cirrus = 10
    Missing = 127
end
end

data_ref = [Clouds.Clear,Clouds.Cumulonimbus,Clouds.Nimbostratus,Clouds.Cirrus]

# create file with enum array

fname = tempname()
ds = NCDataset(fname,"c");
ncv = defVar(ds,"data",data_ref,("x",));
ncv[:] = data_ref
close(ds)

#=
run(`ncdump -h $fname`)
=#

# read enum array

ds = NCDataset(fname);

# reconstructed type

data = ds["data"][:]
#@test eltype(data) <: Enum
NS = NCDatasets.enums(ds["data"].var);
@test data[1] == NS.Clear
@test Integer.(data) == Integer.(data_ref)
@test reinterpret(eltype(data_ref),data) == data_ref
close(ds)

# copy reconstructed variable

fname2 = tempname()
ds = NCDataset(fname2,"c");
defVar(ds,"data",data,("x",))
close(ds)

ds = NCDataset(fname2,"r");
data = ds["data"][:]
@test reinterpret(eltype(data_ref),data) == data_ref

#=
run(`ncdump $fname2`)
run(`ncdump $fname`)
=#


# with provided user-type

ds = NCDataset(fname, typemap = ["cloud_class_t" => Clouds.cloud_class_t])
data = ds["data"][:]
@test eltype(data) == Clouds.cloud_class_t
@test data == data_ref
close(ds)

# write enum attributes

data_ref = [Clouds.Clear,Clouds.Cumulonimbus,Clouds.Nimbostratus,
            Clouds.Cirrus,Clouds.Missing]

fname = tempname()
ds = NCDataset(fname,"c");
defDim(ds,"x",length(data_ref))
ncv = defVar(ds,"data",eltype(data_ref),("x",));
ncv.attrib["_FillValue"] = Clouds.Missing
ds.attrib["attrib_enum"] = Clouds.Clear
ncv[:] = data_ref
close(ds)


# read enum attributes

ds = NCDataset(fname);
NCDatasets.typemap!(ds,"cloud_class_t" => Clouds.cloud_class_t);
data = ds["data"][:]

@test data[1] == Clouds.Clear
@test ismissing(data[end])
@test ds.attrib["attrib_enum"] == Clouds.Clear
close(ds)

# reconstructed types in functions
function test_function()
    ds = NCDataset(fname);
    v = ds["data"][:]
    @test occursin("cloud_class_t",string(typeof(v[1])))
    close(ds)
end
test_function()

# vlen-array of enums

dimlen = 10
T = Clouds.cloud_class_t

data = Vector{Vector{T}}(undef,dimlen)
for i = 1:length(data)
    data[i] = rand(instances(Clouds.cloud_class_t),i)
end

fname = tempname()
ds = NCDataset(fname,"c",format=:netcdf4);
ds.dim["casts"] = dimlen;
vlentypename = "enum-vlen"
#NCDatasets.defType(ds,T,"cloud_class_t")
v = defVar(ds,"data",Vector{T},("casts",); typename = vlentypename)
v.var[:] = data

@test eltype(v.var) == Vector{T}
data2 = v.var[:]
@test data == data2
close(ds)

#=
run(`ncdump -h $fname`)
=#


# enum scalar
fname = tempname()
ds = NCDataset(fname,"c");
defVar(ds,"data",data_ref[1]);
close(ds)

ds = NCDataset(fname,"r", typemap = ["cloud_class_t" => Clouds.cloud_class_t])
@test ds["data"][] == data_ref[1]
close(ds)

ds = NCDataset(fname,"r")
@test reinterpret(Clouds.cloud_class_t, ds["data"][]) == data_ref[1]
close(ds)
