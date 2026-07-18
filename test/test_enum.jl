using Test
using NCDatasets
using NCDatasets: create_enum_type

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
defVar(ds,"data",data_ref,("x",));
close(ds)

run(`ncdump -h $fname`)

# read enum array

ds = NCDataset(fname);
data = ds["data"][:]

# reconstructed type

@test eltype(data) <: Enum
# namespace of the reconstructed enum type (probably need an API)
NS = parentmodule(eltype(data));
@test data[1] == NS.Clear
@test data == reinterpret(eltype(data),data_ref)
@test Integer.(data) == Integer.(data_ref)


# with provided user-type

NCDatasets.usertype!(ds,"cloud_class_t",Clouds.cloud_class_t);

data = ds["data"][:]
@test eltype(data) == Clouds.cloud_class_t
@test data == data_ref

close(ds)

