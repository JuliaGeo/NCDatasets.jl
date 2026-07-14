using Test
using NCDatasets
using NCDatasets: nc_type, check, libnetcdf, nc_inq_user_type, NC_ENUM, ncType, jlType
using NCDatasets: nc_put_att, NC_GLOBAL,
    nc_put_var, nc_def_dim, nc_def_var, nc_insert_enum,
    nc_inq_enum, nc_inq_enum_member, nc_inq_enum_ident, nc_def_enum, nc_get_var!

using NCDatasets.NetCDF_jll: ncdump

#=
# example from https://www.unidata.ucar.edu/software/netcdf/workshops/2011/groups-types/EnumCDL.html


ds = NCDataset("enum.nc");
name = "primary_cloud"

ncid = ds.ncid
varid = NCDatasets.nc_inq_varid(ncid,name)

ndims_ = NCDatasets.nc_inq_varndims(ncid,varid)

ndimsp = Ref(Cint(0))
cname = zeros(UInt8,NCDatasets.NC_MAX_NAME+1)
dimids = zeros(Cint,ndims_)
nattsp = Ref(Cint(0))
xtypep = Ref(NCDatasets.nc_type(0))

NCDatasets.check(ccall((:nc_inq_var,NCDatasets.libnetcdf),Cint,(Cint,Cint,Ptr{UInt8},Ptr{NCDatasets.nc_type},Ptr{Cint},Ptr{Cint},Ptr{Cint}),ncid,varid,cname,xtypep,ndimsp,dimids,nattsp))

xtype = xtypep[]

#nc_inq_enum(int ncid, nc_type xtype, char *name, nc_type *base_nc_typep,
#                 size_t *base_sizep, size_t *num_membersp);


#nc_inq_enum(int ncid, nc_type xtype, char *name, nc_type *base_nc_typep,
#                 size_t *base_sizep, size_t *num_membersp);


name,base_nc_type,base_size,num_members = nc_inq_enum(ncid,xtype)

idx = 0
T = NCDatasets.jlType[base_nc_type]

for idx = 0:num_members-1
    member_name,value = nc_inq_enum_member(ncid,xtype,T,idx)
    @show member_name,value
end
=#

# create a file with enum type

fname = tempname()
#fname = "enum4.nc"
#rm(fname)
ds = NCDataset(fname,"c");
ncid = ds.ncid

T = Int8

base_typeid = ncType[T]

#=
# recreate file
https://raw.githubusercontent.com/Unidata/netcdf-c/refs/tags/v4.7.4/dap4_test/nctestfiles/test_enum_array.nc

netcdf test_enum_array {
types:
  byte enum cloud_class_t {Clear = 0, Cumulonimbus = 1, Stratus = 2,
      Stratocumulus = 3, Cumulus = 4, Altostratus = 5, Nimbostratus = 6,
      Altocumulus = 7, Cirrostratus = 8, Cirrocumulus = 9, Cirrus = 10,
      Missing = 127} ;
dimensions:
        d5 = 5 ;
variables:
        cloud_class_t primary_cloud(d5) ;
                cloud_class_t primary_cloud:_FillValue = Missing ;
data:

 primary_cloud = Clear, Stratus, Clear, Cumulonimbus, _ ;
}


=#

type_name = "cloud_class_t"
typeid = nc_def_enum(ncid,base_typeid,type_name)


members = Pair{String,T}[
    "Clear" => 0,
    "Cumulonimbus" => 1,
    "Stratus" => 2,
    "Stratocumulus" => 3,
    "Cumulus" => 4,
    "Altostratus" => 5,
    "Nimbostratus" => 6,
    "Altocumulus" => 7,
    "Cirrostratus" => 8,
    "Cirrocumulus" => 9,
    "Cirrus" => 10,
    "Missing" => 127,
]



members_dict = Dict(members)

for (member_name,member_value) in members
    nc_insert_enum(ncid,typeid,member_name,member_value,T)
end


dimid = nc_def_dim(ncid,"d5",5)

# add variable
varname = "primary_cloud"
xtype = typeid
dimids = [dimid]
varid =  nc_def_var(ncid,varname,xtype,dimids)
nc_put_att(ncid, varid, "_FillValue", typeid, [Int8(127)])

data = T[0, 2, 0, 1, 127]
nc_put_var(ncid,varid,data)


# put enum attribute
nc_put_att(ncid, NC_GLOBAL, "enum_attrib", typeid, [Int8(0)])
sync(ds)




# read enum type

name2,size2,base_nc_type2,nfields2,class2 = nc_inq_user_type(ncid,typeid)

@test name2 == type_name
@test base_nc_type2 == base_typeid
@test nfields2 == length(members)
@test class2 == NC_ENUM

name2,base_nc_type2,base_size2,num_members2 = nc_inq_enum(ncid,typeid)

@test name2 == type_name
@test base_nc_type2 == T
@test base_size2 == sizeof(T)
@test num_members2 == length(members)

for idx = 0:num_members2-1
    member_name,value = nc_inq_enum_member(ncid,typeid,idx,T)
    @test members_dict[member_name] == value
    identifier = nc_inq_enum_ident(ncid,typeid,value)
    @test identifier == member_name
end

data2 = similar(data)
nc_get_var!(ncid,varid,data2)

# scope enums by modules to avoid conflicts
#
# https://discourse.julialang.org/t/encapsulating-enum-access-via-dot-syntax/11785/2
# https://github.com/fredrikekre/EnumX.jl

baremodule module_cloud_class_t
using Base: @enum
@enum cloud_class_t::Int8 begin
    Clear = Int8(0)
    Cumulonimbus = Int8(1)
    Stratus = Int8(2)
    Stratocumulus = Int8(3)
    Cumulus = Int8(4)
    Altostratus = Int8(5)
    Nimbostratus = Int8(6)
    Altocumulus = Int8(7)
    Cirrostratus = Int8(8)
    Cirrocumulus = Int8(9)
    Cirrus = Int8(10)
    Missing = Int8(127)
end
end

data3 = Vector{module_cloud_class_t.cloud_class_t}(undef,5)
nc_get_var!(ncid,varid,data3)

@show data3

# Create enum type dynamically scoped by a module (to avoid name conflicts)

modname = Symbol("mod_" * name2)
typename = Symbol(name2)

mod = eval(:(module $modname end))

Core.eval(mod,
          Expr(:macrocall,
               Symbol("@enum"),
               :(),
               :($(Symbol(name2))::$T),
               [:($(Symbol(n)) = $v) for (n,v) in members]...
                   ))


data4 = Vector{getproperty(mod,typename)}(undef,5)
nc_get_var!(ncid,varid,data4)

@show data4

# Instrospect an array of enums

full_typename = string(eltype(data4))
typename = last(split(full_typename,'.')) # strip module prefix
members2 = [Symbol(inst) => Integer(inst) for inst in instances(eltype(data4))]

close(ds)
#sync(ds)
run(`$(ncdump()) $fname`)

