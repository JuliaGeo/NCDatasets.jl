using Base.Threads
using DataStructures
using NCDatasets
using Test


fname = (length(ARGS) > 0 ? ARGS[1] : tempname())
ntasks = (length(ARGS) > 1 ? parse(Int,ARGS[2]) : 100)

#format = :netcdf5_64bit_data
format = :netcdf4

ds = NCDataset(fname,"c"; format)

data = [Float32(i+j) for i = 1:100, j = 1:110];

kwargs =
    if format == :netcdf5_64bit_data
        (; )
    else
        (; deflatelevel = 6,
         shuffle = true,
         chunksizes = (10,10),
         )
    end

function defnc(ds,t,data)
    sleep(rand() * 0.01) # jitter
    defDim(ds,"lon$t",100)
    defDim(ds,"lat$t",110)
    ds.attrib["title$t"] = "this is a test file"
    v = defVar(ds,"temperature$t",Float32,("lon$t","lat$t");
               attrib = OrderedDict(
                   "units" => "degree Celsius",
                   "scale_factor" => 10,
               ), kwargs...)

    @test ds.attrib["title$t"] == "this is a test file"
    @test v.attrib["units"] == "degree Celsius"
    @test v.attrib["scale_factor"] == 10

    v[:,:] = data;
    return nothing
end

chunks = 1:ntasks

tasks = map(chunks) do t
    Threads.@spawn defnc(ds,t,data);
end
fetch.(tasks)

close(ds)

