using Test
using NCDatasets
using NCDatasets: nc_create, NC_NETCDF4, NC_CLOBBER, NC_NOWRITE, nc_def_dim, nc_def_compound, nc_insert_compound, nc_def_var, nc_put_var, nc_close, NC_INT, nc_unsafe_put_var, libnetcdf, check, ncType, nc_open, nc_inq_vartype, nc_inq_compound_nfields, nc_inq_compound_size, nc_inq_compound_name, nc_inq_compound_fieldoffset,nc_inq_compound_fieldndims,nc_inq_compound_fielddim_sizes, nc_inq_compound_fieldname, nc_inq_compound_fieldindex, nc_inq_compound_fieldtype, nc_inq_compound, nc_inq_varid, nc_get_var!, nc_insert_array_compound, reconstruct_compound_type, create_compound_type


using NCDatasets: usertype, usertype!
# mutable struct are not supported
# https://discourse.julialang.org/t/passing-an-array-of-structures-through-ccall/5194

struct s1
    i1::Cint
    i2::Cint
    f1::Cfloat
    d1::Cdouble
    foo::NTuple{3,Cint}
end

sz = (2,3)

data = Array{s1,2}(undef,sz)


for j = 1:sz[2]
    for i = 1:sz[1]
        data[i,j] = s1(i,j,1.2,2.3,(2,i,j))
    end
end


T = eltype(data)
filename = tempname()

isfile(filename) && rm(filename)
ncid = nc_create(filename, NC_NETCDF4|NC_CLOBBER)

x_dimid = nc_def_dim(ncid, "x", sz[1])
y_dimid = nc_def_dim(ncid, "y", sz[2])

dimids = [x_dimid, y_dimid]

type_name = "sample_compound_type"
typeid = create_compound_type(ncid,T,type_name);

varid = nc_def_var(ncid, "data", typeid, reverse(dimids))

nc_put_var(ncid, varid, data)
nc_close(ncid)


#=
run(`ncdump $filename`)
=#

ncid = nc_open(filename,NC_NOWRITE)

varid = nc_inq_varid(ncid,"data")
xtype = nc_inq_vartype(ncid,varid)

@test nc_inq_compound_name(ncid,xtype) == "sample_compound_type"
@test nc_inq_compound_size(ncid,xtype) == sizeof(T)
@test nc_inq_compound_nfields(ncid,xtype) == fieldcount(T)

fieldid = 0

@test nc_inq_compound_fieldname(ncid,xtype,fieldid) == String(fieldnames(T)[fieldid+1])

_fieldname = String(fieldnames(T)[1])
@test nc_inq_compound_fieldindex(ncid,xtype,_fieldname) == 0


@test nc_inq_compound_fieldoffset(ncid,xtype,fieldid) == 0

nc_inq_compound_fieldoffset(ncid,xtype,1)


@test nc_inq_compound_fieldtype(ncid,xtype,fieldid) == ncType[fieldtype(T,fieldid+1)]


@test nc_inq_compound_fieldndims(ncid,xtype,fieldid) == 0

dim_sizes = nc_inq_compound_fielddim_sizes(ncid,xtype,fieldid)


type_name,type_size,type_nfields = nc_inq_compound(ncid,xtype)

@test type_name == "sample_compound_type"
@test type_size == sizeof(T)
@test type_nfields == fieldcount(T)

usertypes = Dict()
T2 = reconstruct_compound_type(ncid,xtype,usertypes)

data2 = Array{T2,2}(undef,sz...)

nc_get_var!(ncid, varid, data2)

@test data2[1,1].i1 == data[1,1].i1


for fn = fieldnames(eltype(data2))
    @test getproperty.(data,fn) == getproperty.(data2,fn)
end

nc_close(ncid)


run(`ncdump $filename`)


using Downloads: download

fname = download("https://raw.githubusercontent.com/Unidata/netcdf-c/refs/tags/v4.8.1/dap4_test/nctestfiles/test_struct_array.nc")
ds = NCDataset(fname)

array = ds["s"].var[:,:]
@test array[1,1].x == 1
@test array[1,1].y == -1

@test array[1,2].x == -1
@test array[1,2].y == 3

close(ds)
#run(`ncdump $fname`)


fname = tempname()
ds = NCDataset(fname,"c")
defDim(ds,"x",2)
defDim(ds,"y",3)
ncv = defVar(ds,"data",s1,("x","y"))

@test eltype(ncv) == s1
ncv[:,:] = data
close(ds)

ds = NCDataset(fname)
data_loaded = ds["data"][:,:]

T = typeof(data_loaded[1,1])

@test usertype(ds,:s1) == T
@test sizeof(T) == sizeof(s1)
@test fieldcount(T) == fieldcount(s1)
for i = 1:fieldcount(T)
    @test fieldoffset(T,i) == fieldoffset(s1,i)
    @test fieldtype(T,i) == fieldtype(s1,i)
end

@test data_loaded[1,1].i1 == data[1,1].i1

@test typeof(ds["data"][1,1]) == T


usertype!(ds,:s1,s1)

data_loaded = ds["data"][:,:]
@test eltype(data_loaded) == s1
@test data_loaded == data

run(`ncdump $fname`)
