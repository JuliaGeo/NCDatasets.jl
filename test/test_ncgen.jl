using NCDatasets
using Test

ncfile1 = tempname()
ncfile2 = tempname()
jlfile = tempname()
#jlfile = "/tmp/out.jl"

ds = NCDataset(ncfile1,"c")
ds.dim["lon"] = 3;
ds.dim["lat"] = 4;
ds.dim["unlimited"] = Inf;
nclon = defVar(ds,"variable with space", Float32, ("lon",))
nclon.attrib["string"] = "degrees_east";
nclon.attrib["float32"] = Float32(1.)
nclon.attrib["float64"] = 1.
nclon.attrib["float32_vector"] = Float32[1.,2.,3.]
nclon.attrib["float64_vector"] = [1.,2.,3.]
nclon.attrib["int32_vector"] = Int32[1,2,3]


ds.attrib["dollar"] = "a dollar \$ stop";
ds.attrib["backslash"] = "a backslash \\ stop";
ds.attrib["doublequote"] = "a doublequote \" stop";

ncmatrix = defVar(ds,"matrix", Float32,("lon","lat"))


close(ds)

ncgen(ncfile1,jlfile; newfname = ncfile2)
include(jlfile)

buf1 = IOBuffer()
buf2 = IOBuffer()

ncgen(buf1,ncfile1)
ncgen(buf2,ncfile2)

@test String(take!(buf1)) == String(take!(buf2))

rm(ncfile1)
rm(ncfile2)
rm(jlfile)
