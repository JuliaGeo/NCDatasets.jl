using NCDatasets
using NCDatasets: quantize

sz = (40,10)
filename = tempname()

ds = NCDataset(filename,"c")

defDim(ds,"lon",sz[1])
defDim(ds,"lat",sz[2])


T = Float64
for T in [UInt8,Int8,UInt16,Int16,UInt32,Int32,UInt64,Int64,Float32,Float64]
    #for T in [Float32]
    local data
    data = fill(T(123),sz)

    v = defVar(ds,"var-$T",T,("lon","lat");
               shuffle = true,
               chunksizes = (20,5),
               deflatelevel = 9,
               checksum = :nochecksum
               )
    # check checksum method
    checksummethod = checksum(v)
    @test checksummethod == :nochecksum

    # change checksum method
    checksum(v,:fletcher32)
    checksummethod = checksum(v)
    @test checksummethod == :fletcher32

    # check chunking
    storage,chunksizes = chunking(v)
    @test storage == :chunked
    @test chunksizes[1] == 20

    # change chunking
    chunking(v,:chunked,(3,3))
    storage,chunksizes = chunking(v)
    @test storage == :chunked
    #@show chunksizes
    @test chunksizes[1] == 3

    # check compression
    isshuffled,isdeflated,deflate_level = deflate(v)
    @test isshuffled == true
    @test isdeflated == true
    @test deflate_level == 9

    # change compression
    deflate(v,false,true,4)
    isshuffled,isdeflated,deflate_level = deflate(v)
    # cannot be changed
    #@test_broken isshuffled == false
    @test isdeflated == true
    @test deflate_level == 4

    # write an array
    v[:,:] = data
    @test all(v[:,:] .== data)


    v = defVar(ds,"var2-$T",T,("lon","lat");
               shuffle = true,
               chunksizes = (20,5),
               deflatelevel = 9,
               checksum = :fletcher32
               )
    checksummethod = checksum(v)
    @test checksummethod == :fletcher32
end
close(ds)


# quantization
T = Float32
data = fill(T(123),sz)

fname = tempname()
ds = NCDataset(fname,"c")
defDim(ds,"lon",sz[1])
defDim(ds,"lat",sz[2])
v = defVar(ds,"var3-$T",T,("lon","lat"));

quantize(v.var,:BitGroom,5)
mode,nsd = quantize(v.var)
@test mode == :BitGroom
@test nsd == 5

v[:,:] = data
@test v[:,:] ≈ data rtol=1e-5
close(ds)
