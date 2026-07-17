using NCDatasets
using Test
using Dates
using Printf

sz = (4,5)
filename = tempname()
# The mode "c" stands for creating a new file (clobber)
ds = NCDataset(filename,"c")

# define the dimension "lon" and "lat"
defDim(ds,"lon",sz[1])
defDim(ds,"lat",sz[2])

# vartype not supported (currently broken)
#@test_throws ErrorException defVar(ds,"var-DT",DateTime,("lon","lat"))

# variables
for T in [UInt8,Int8,UInt16,Int16,UInt32,Int32,UInt64,Int64,Float32,Float64]
    #for T in [Float32]
    local v, ref

    # write array
    v = defVar(ds,"var-$T",T,("lon","lat"))

    # write array
    v[:,:] = fill(T(123),size(v))
    @test all(v[:,:][:] .== 123)

    # write scalar
    v[:,:] .= T(100)
    @test all(v[:,:][:] .== 100)

    # write array (different type)
    v[:,:] = fill(123,size(v))
    @test all(v[:,:][:] .== 123)

    # write scalar (different type)
    v[:,:] .= 100
    @test all(v[:,:][:] .== 100)

    # using StepRange as index
    # write array
    v[1:end,1:end] = fill(T(123),size(v))
    @test all(v[:,:][:] .== 123)

    # write scalar
    v[1:end,1:end] .= T(100)
    @test all(v[:,:][:] .== 100)

    # write array (different type)
    v[1:end,1:end] = fill(123,size(v))
    @test all(v[:,:][:] .== 123)

    # write scalar (different type)
    v[1:end,1:end] .= 100
    @test all(v[:,:][:] .== 100)


    # step range
    ref = zeros(sz)
    v[:,:] .= 0

    ref[1:2:end,2:2:end] .= 1
    v[1:2:end,2:2:end] .= 1
    @test v[:,:] == ref

    # write scalar (different type)
    ref[1:2:end,2:2:end] .= UInt8(2)
    v[1:2:end,2:2:end] .= UInt8(2)
    @test v[:,:] == ref

    ref[1,1] = 3
    v[1,1] = 3

    @test v[:,:] == ref
end

v = defVar(ds,"var-Char",Char,("lon","lat"))

# write array (without transformation)
v.var[:,:] = fill('a',size(v))
@test all(i -> i == 'a',v.var[:,:][:])

v.var[1,1] = 'x'
@test v.var[1,1] == 'x'
@test v.var[1,2] == 'a'

# write scalar
v.var[:,:] .= 'b'
@test all(i -> i == 'b',v.var[:,:][:])

# write array (with transformation)
v[:,:] = fill('c',size(v))
@test all(i -> i == 'c',v.var[:,:][:])

# write scalar
v[:,:] .= 'd'
@test all(i -> i == 'd',v.var[:,:][:])

# using StepRange as index
# write array (without transformation)
v.var[1:end,1:end] = fill('e',size(v))
@test all(i -> i == 'e',v.var[:,:][:])

# write scalar
v.var[1:end,1:end] .= 'f'
@test all(i -> i == 'f',v.var[:,:][:])

# write array (with transformation)
v[1:end,1:end] = fill('g',size(v))
@test all(i -> i == 'g',v.var[:,:][:])

# write scalar
v[1:end,1:end] .= 'h'
@test all(i -> i == 'h',v.var[:,:][:])

# write with StepRange
v[:,:] .= 'h'
ref = fill('h',sz)

ref[1:2:end,1:2:end] .= Ref('i')
#ref[1:2:end,1:2:end] .= 'i'
v[1:2:end,1:2:end] .= 'i'

@test v[:,:] == ref


ref = ['a'+i+2*j for i = 0:sz[1]-1, j= 0:sz[2]-1]
v[:,:] = ref

@test v.var[1:1,1:1] == ref[1:1,1:1]
@test v.var[1,1] == ref[1,1]
@test v.var[2:3,1] == ref[2:3,1]

#@test v[1,1] == ref[1,1]

@test dimnames(v) == ("lon","lat")
@test name(v) == "var-Char"

close(ds)
