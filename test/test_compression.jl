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


# Zstandard compression
# The filter is provided by H5Zzstd, which registers it with the HDF5 library
# shared by libnetcdf when loaded.
using H5Zzstd
using NCDatasets: zstandard

sz = (100,100)
data = Float32.(repeat(1:sz[1],1,sz[2]))

fname_zstd = tempname()
NCDataset(fname_zstd,"c") do ds
    @test NCDatasets.nc_inq_filter_avail(ds.ncid,NCDatasets.H5Z_FILTER_ZSTD)

    defDim(ds,"lon",sz[1])
    defDim(ds,"lat",sz[2])

    v = defVar(ds,"temp",Float32,("lon","lat"); chunksizes = (50,50), zstdlevel = 5)
    iszstd,level = zstandard(v)
    @test iszstd
    @test level == 5

    # set after defVar
    v2 = defVar(ds,"temp2",Float32,("lon","lat"); chunksizes = (50,50))
    zstandard(v2,1)
    iszstd,level = zstandard(v2)
    @test iszstd
    @test level == 1

    # not compressed
    v3 = defVar(ds,"temp3",Float32,("lon","lat"))
    iszstd,level = zstandard(v3)
    @test !iszstd

    v[:,:] = data
    v2[:,:] = data
    v3[:,:] = data
end

# the compressible data must actually be compressed: same file without compression
fname_raw = tempname()
NCDataset(fname_raw,"c") do ds
    defDim(ds,"lon",sz[1])
    defDim(ds,"lat",sz[2])
    for vname in ("temp","temp2")
        v = defVar(ds,vname,Float32,("lon","lat"); chunksizes = (50,50))
        v[:,:] = data
    end
    v3 = defVar(ds,"temp3",Float32,("lon","lat"))
    v3[:,:] = data
end
@test filesize(fname_zstd) < filesize(fname_raw)

# read back and copy (compression settings must be preserved)
fname_copy = tempname()
NCDataset(fname_zstd) do ds
    @test ds["temp"][:,:] == data
    @test ds["temp2"][:,:] == data
    @test zstandard(ds["temp"]) == (true,5)
    @test zstandard(ds["temp2"]) == (true,1)

    NCDataset(fname_copy,"c") do ds_copy
        defVar(ds_copy,ds["temp"])
        defVar(ds_copy,ds["temp3"])
    end
end
NCDataset(fname_copy) do ds_copy
    @test zstandard(ds_copy["temp"]) == (true,5)
    @test zstandard(ds_copy["temp3"]) == (false,0)
    @test ds_copy["temp"][:,:] == data
end

# no filter can be set on NetCDF-3 files
fname_nc3 = tempname()
NCDataset(fname_nc3,"c",format = :netcdf3_64bit_offset) do ds
    defDim(ds,"lon",sz[1])
    @test !NCDatasets.nc_inq_filter_avail(ds.ncid,NCDatasets.H5Z_FILTER_ZSTD)
    @test_throws ErrorException defVar(ds,"temp",Float32,("lon",); zstdlevel = 5)
    # copying a NetCDF-3 variable must not fail when querying its (absent) filters
    v = defVar(ds,"temp3",Float32,("lon",))
    @test zstandard(v) == (false,0)
end

rm(fname_zstd)
rm(fname_raw)
rm(fname_copy)
rm(fname_nc3)
