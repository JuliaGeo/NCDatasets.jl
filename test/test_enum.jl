using Test
using NCDatasets
using NCDatasets: nc_type, check, libnetcdf, nc_inq_user_type,
    NC_ENUM, ncType, jlType, nc_put_att, NC_GLOBAL,
    nc_put_var, nc_def_dim, nc_def_var, nc_insert_enum,
    nc_inq_enum, nc_inq_enum_member, nc_inq_enum_ident, nc_def_enum, nc_get_var!

using NCDatasets.NetCDF_jll: ncdump
using BenchmarkTools
using CategoricalArrays

# scope enums by modules to avoid conflicts
#
# https://discourse.julialang.org/t/encapsulating-enum-access-via-dot-syntax/11785/2
# https://github.com/fredrikekre/EnumX.jl

baremodule module_cloud_class_t
using Base: @enum
@enum cloud_class_t::Int8 begin
    Clear = 0
    Cumulonimbus = 1
    Stratus = 2
    Stratocumulus = 3
    Cumulus = 4
    Altostratus = 5
    Nimbostratus = 6
    Altocumulus = 7
    Cirrostratus = 8
    Cirrocumulus = 9
    Cirrus = 10
    Missing = 127
end
end

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

# create a file with enum type

fname = tempname()
#fname = "enum4.nc"
#rm(fname)
ds = NCDataset(fname,"c");
ncid = ds.ncid
T = Int8

base_typeid = ncType[T]

type_name = "cloud_class_t"
typeid = nc_def_enum(ncid,base_typeid,type_name)

# prefer a vector to maintain order
members = Pair{Symbol,T}[
    :Clear => 0,
    :Cumulonimbus => 1,
    :Stratus => 2,
    :Stratocumulus => 3,
    :Cumulus => 4,
    :Altostratus => 5,
    :Nimbostratus => 6,
    :Altocumulus => 7,
    :Cirrostratus => 8,
    :Cirrocumulus => 9,
    :Cirrus => 10,
    :Missing => 127,
]

members_dict = Dict(members)

for (member_name,member_value) in members
    nc_insert_enum(ncid,typeid,member_name,member_value,T)
end

len = 100_000
dimid = nc_def_dim(ncid,"d5",len)

# add variable
varname = "primary_cloud"
xtype = typeid
dimids = [dimid]
varid =  nc_def_var(ncid,varname,xtype,dimids)
nc_put_att(ncid, varid, "_FillValue", typeid, [Int8(127)])

data = T[0, 2, 0, 1, 127]
data = rand(values(members_dict),len)

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
    @test members_dict[Symbol(member_name)] == value
    identifier = nc_inq_enum_ident(ncid,typeid,value)
    @test identifier == member_name
end

# read data


data3 = Vector{module_cloud_class_t.cloud_class_t}(undef,len)
nc_get_var!(ncid,varid,data3)

#@show data3
# correct

# Create enum type dynamically scoped by a module (to avoid name conflicts)

function enum_type(mod,T,name2,members)
    typename = Symbol(name2)

    if typename in names(mod,all=true)
        return getproperty(mod,typename)
    end

    Core.eval(mod,
              Expr(:macrocall,
                   Symbol("@enum"),
                   :(),
                   :($(Symbol(name2))::$T),
                   [:($(Symbol(n)) = $v) for (n,v) in members]...
                       ))

    invokelatest() do
        return getproperty(mod,typename)
    end
end


function load_enum(ET,ncid,varid,len)
    data4 = Vector{ET}(undef,len)
    nc_get_var!(ncid,varid,data4)
    return data4
end

# Benchmark use case:
# a file is opened and an NCDatasets.Variable is instanciated once and then
# there are many read operation to the NCDatasets.Variable

# to be done during the instantiation of NCDatasets.Variable
modname = Symbol("mod_" * name2)
mod = eval(:(module $modname end))
ET = enum_type(mod,T,name2,members);

# load data
data4 = @btime load_enum(ET,ncid,varid,len);


data4a = load_enum(ET,ncid,varid,len);

# based on PR
# https://github.com/JuliaGeo/CommonDataModel.jl/pull/53

function _sorted_labels(mapping::AbstractDict{R, V}) where {R, V}
    sorted_codes = sort(collect(keys(mapping)))
    return V[mapping[c] for c in sorted_codes]
end



# __let me know if this can be done more efficiently__
function load_CategoricalArray(T,ncid,varid,len,levels,mapping)
    raw = Vector{T}(undef,len);
    nc_get_var!(ncid,varid,raw)
    # creating a vector of strings (is there a better way?)
    label_values = [mapping[c] for c in raw]
    return CategoricalArray{String, 1, T}(label_values; levels)
end

# to be done during the instantiation of NCDatasets.Variable
mapping = Dict((v => String(name) for (name,v) in members)...)
levels =_sorted_labels(mapping)

# load data
data5 = @btime load_CategoricalArray(T,ncid,varid,len,levels,mapping);


# Instrospect an array of enums

full_typename = string(eltype(data4))
typename = last(split(full_typename,'.')) # strip module prefix
members2 = [Symbol(inst) => Integer(inst) for inst in instances(eltype(data4))]

#close(ds)
sync(ds)
#run(`$(ncdump()) -h $fname`)
