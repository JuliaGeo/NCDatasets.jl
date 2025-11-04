using NCDatasets
using Test
sz = (4,5)
filename = tempname()
#filename = "/tmp/mytest.nc"


NCDataset(filename,"c") do ds

    ds.dim["lon"] = sz[1]
    ds.dim["lat"] = sz[2]

    v = defVar(ds,"temperature",Float32,("lon","lat"),
                          attrib = ["long_name" => "Temperature",
                                    "test_vector_attrib" => [1,2,3]])

    # write attributes
    v.attrib["units"] = "degree Celsius"
    v.attrib["comment"] = "this is a string attribute with unicode Ω ∈ ∑ ∫ f(x) dx "

    # check presence of attribute
    @test haskey(v.attrib,"comment")
    @test v.attrib["long_name"] == "Temperature"
    @test v.attrib[:long_name] == "Temperature"
    @test v.attrib["test_vector_attrib"] == [1,2,3]
    @test v.attrib["comment"] == "this is a string attribute with unicode Ω ∈ ∑ ∫ f(x) dx "

    @test get(v.attrib,"does-not-exist","default") == "default"
    @test get(v.attrib,"units","default") == "degree Celsius"

    # test deletion of attributes
    v.attrib["todelete"] = "foobar"
    @test haskey(v.attrib,"todelete")
    delete!(v.attrib,"todelete")
    @test !haskey(v.attrib,"todelete")

    for T in [UInt8,Int8,UInt16,Int16,UInt32,Int32,UInt64,Int64,Float32,Float64,
              String,Char]
        # scalar attribute
        name = "scalar-attrib-$T"

        refdata =
            if T == Char
                'a'
            elseif T == String
                "abc"
            else
                123
            end

        v.attrib[name] = T(refdata)
        attval = v.attrib[name]

        if T == Char
            # a single Char is returned as strings
            @test typeof(attval) == String
            @test attval[1] == refdata
        else
            if T == Int64
                # not supported in NetCDF, converted as Int32
                @test typeof(attval) in [Int32,Int64]
            else
                @test typeof(attval) == T
            end

            @test attval == refdata
        end

        # vector attribute
        name = "vector-attrib-$T"

        refvecdata =
            if T == Char
                ['a','b']
            elseif T == String
                ["abc","xyz"]
            else
                [1,2,3,4]
            end


        attval = T.(refvecdata)
        attval = attval

        if T == Char
            # vector of Char are returned as strings
            @test eltype(attval) == T
            @test Vector{Char}(attval) == refvecdata
        else
            if T == Int64
                # not supported in NetCDF, converted as Int32
                @test eltype(attval) in [Int32,Int64]
            else
                @test eltype(attval) == T
            end

            @test attval == refvecdata
        end

    end

    # arrays cannot be attributes
    @test_throws ErrorException v.attrib["error_attrib"] = zeros(2,2)

    # symbols in the attrib dict
    foo = defVar(ds,"foovar",Int64,("lon","lat"),
                            attrib = [:long_name => "foo variable"])
    @test foo.attrib["long_name"] == "foo variable"

end

rm(filename)

filename = tempname()

NCDataset(filename,"c",format = :netcdf3_classic) do ds
    # test deletion of attributes
    ds.attrib["todelete"] = "foobar"
end

NCDataset(filename,"a") do ds
    @test haskey(ds.attrib,"todelete")
    delete!(ds.attrib,"todelete")
    @test !haskey(ds.attrib,"todelete")
end

rm(filename)


#filename = "/tmp/mytest.nc"

# test untyped attributes
filename = tempname()
vector_attrib = Any[Int32(1),Int32(2)]
ds = NCDataset(filename,"c")
# test deletion of attributes
ds.attrib["vector_attrib"] = vector_attrib
@test ds.attrib["vector_attrib"] == vector_attrib
close(ds)
