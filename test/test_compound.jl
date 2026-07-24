using Test
using NCDatasets
using NCDatasets: typemap, typemap!


# write file similar to
# https://raw.githubusercontent.com/Unidata/netcdf-c/refs/tags/v4.8.1/dap4_test/nctestfiles/test_struct_array.nc

struct MyCompoundType
    x::Int32
    y::Int32
end

dx = 4
dy = 3

array_ref = [MyCompoundType.(i,j) for i = 1:dx, j = 1:dy]
fname = tempname()
ds = NCDataset(fname,"c")
defDim(ds,"dx",dx)
defDim(ds,"dy",dy)
ncv = defVar(ds,"s",MyCompoundType,("dx","dy"); typename = "c_t")
ncv[:] = array_ref
close(ds)


# or more compactly:

NCDataset(fname,"c") do ds
    # dimension "dim" is created automatically
    ncv = defVar(ds,"s",array_ref,("dx","dy"); typename = "c_t")
end

# load data

ds = NCDataset(fname)
array = ds["s"][:,:]

@test occursin("c_t",string(typeof(array)))

NCDatasets.typemap!(ds,"c_t" => MyCompoundType)
array = ds["s"][:,:]

@test eltype(array) == MyCompoundType
@test array == array_ref

close(ds)

#run(`ncdump $fname`)


struct MyStruct2
    i1::Cint
    i2::Cint
    f1::Cfloat
    d1::Cdouble
    foo::NTuple{3,Cint}
end


sz = (2,3)
data = [MyStruct2(i,j,1.2,2.3,(2,i,j)) for i = 1:sz[1], j = 1:sz[2]]

fname = tempname()
ds = NCDataset(fname,"c")
defDim(ds,"x",2)
defDim(ds,"y",3)
ncv = defVar(ds,"data",MyStruct2,("x","y"); typename = "nc_compound_t")

@test eltype(ncv) == MyStruct2
ncv[:,:] = data
close(ds)

ds = NCDataset(fname)
data_loaded = ds["data"][:,:]

T = typeof(data_loaded[1,1])

@test typemap(ds,"nc_compound_t") == T
@test sizeof(T) == sizeof(MyStruct2)

@test propertynames(data_loaded[1]) == propertynames(data[1])

#=
@test fieldcount(T) == fieldcount(MyStruct2)
for i = 1:fieldcount(T)
    @test fieldoffset(T,i) == fieldoffset(MyStruct2,i)
    @test fieldtype(T,i) == fieldtype(MyStruct2,i)
end
=#
@test data_loaded[1,1].i1 == data[1,1].i1

@test typeof(ds["data"][1,1]) == T


typemap!(ds,"nc_compound_t" => MyStruct2)

data_loaded = ds["data"][:,:]
@test eltype(data_loaded) == MyStruct2
@test data_loaded == data

#run(`ncdump $fname`)

# two NetCDF file using the same compound type name but with different layout
n = 10

struct Complex1
    r::Float32
    i::Float32
end

data1 = Complex1.(rand(Float32,n),rand(Float32,n))

fname1 = tempname()
NCDataset(fname1,"c") do ds1
    defVar(ds1,"data",data1,("x",); typename = "Complex")
end

struct Complex2
    real::Float64
    imag::Float64
end

data2 = Complex2.(rand(Float64,n),rand(Float64,n))

fname2 = tempname()
NCDataset(fname2,"c") do ds2
    defVar(ds2,"data",data2,("x",); typename = "Complex")
end

#run(`ncdump $fname2`)

ds1 = NCDataset(fname1);
@test ds1["data"][1].r == data1[1].r

ds2 = NCDataset(fname2);
@test ds2["data"][1].real == data2[1].real


# Non-algined data

struct NonAlignedType
    float_field::Float32
    int_field::Int32
    byte_field::Int8
end

array_ref = [NonAlignedType(i,i,i) for i = 1:10]
fname = tempname()

NCDataset(fname,"c") do ds
    ncv = defVar(ds,"data",array_ref,("n",))
end

# load data

ds = NCDataset(fname)
array = ds["data"][:]
close(ds)

#=
run(`ncdump $fname`)
=#

# vlen-array of structs

dimlen = 10
T = MyCompoundType

data = Vector{Vector{T}}(undef,dimlen)
for i = 1:length(data)
    data[i] = [MyCompoundType.(j,j) for j = 1:i]
end

fname = tempname()
ds = NCDataset(fname,"c",format=:netcdf4);
ds.dim["casts"] = dimlen;
vlentypename = "struct-vlen"
#NCDatasets.defType(ds,T,"cloud_class_t")
v = defVar(ds,"data",Vector{T},("casts",); typename = vlentypename)
v.var[:] = data

@test eltype(v) == Vector{T}
data2 = v[:]
@test data == data2
close(ds)
