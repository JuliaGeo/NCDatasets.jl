using Base.Threads
using DataStructures
using NCDatasets
using Test

fname = ARGS[1]
ds = NCDataset(fname,"c")

data = [Float32(i+j) for i = 1:100, j = 1:110];

function defnc(ds,t,data)
    defDim(ds,"lon$t",100)
    defDim(ds,"lat$t",110)
    ds.attrib["title$t"] = "this is a test file"
    v = defVar(ds,"temperature$t",Float32,("lon$t","lat$t"),
               deflatelevel = 6,
               shuffle = true,
               chunksizes = (10,10),
               attrib = OrderedDict(
                   "units" => "degree Celsius",
                   "scale_factor" => 10,
               ))
    v[:,:] = data;
    return nothing
end

chunks = 1:100

tasks = map(chunks) do t
    Threads.@spawn defnc(ds,t,data);
end
fetch.(tasks)

close(ds)

