using Test
using NCDatasets
using NCDatasets: typemap, typemap!

struct Position
    lon::Float32
    lat::Float32
end

struct Obs
    temperature::Float32
    humidity::Int32
    position::Position
end

data_ref = [Obs(22.5, 65, Position(1,2))]


# create variable with nested compounds types
fname = tempname()
ds = NCDataset(fname,"c");
defVar(ds,"weather_reports",data_ref,("station",))
close(ds)

#run(`ncdump $fname`)

# read variable with nested compounds types

ds = NCDataset(fname);
data = ds["weather_reports"][:]
@test data[1].temperature == 22.5

typemap!(ds,"Obs" => Obs)
data = ds["weather_reports"][:]
@test data == data_ref

close(ds)


# vector of user types

struct ObsGrid
    id::Int32
    position::NTuple{3,Position}
end

data_ref = [ObsGrid(42,Position.((1,2,3),(10,20,30)))]
fname = tempname()
ds = NCDataset(fname,"c");
defVar(ds,"data",data_ref,("n",))
close(ds)

ds = NCDataset(fname);
@test ds["data"][1].id == 42

typemap!(ds,"ObsGrid" => ObsGrid)
@test ds["data"][:] == data_ref

close(ds)


# deeply nested

struct Profile
    position::Position
    temperature::NTuple{3,Float32}
end

struct Entry
    id::Int32
    profile::Profile
end

data_ref = [Entry(404,Profile(Position(1,2),(1,2,3)))]

fname = tempname()
ds = NCDataset(fname,"c");
defVar(ds,"data",data_ref,("n",))
close(ds)

ds = NCDataset(fname);
data = ds["data"][:]
@test data[1].id == data_ref[1].id
@test data[1].profile.position.lon == data_ref[1].profile.position.lon

typemap!(ds,"Entry" => Entry)
data = ds["data"][:]
@test data == data_ref
