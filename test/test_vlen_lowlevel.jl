import NCDatasets

filename = tempname()

dimlen = 10


T = Int32
data = Vector{Vector{T}}(undef,dimlen)
for i = 1:length(data)
    data[i] = T.(collect(1:i) .+ 100 * i)
end

ncdata = Vector{NCDatasets.nc_vlen_t{T}}(undef,dimlen)

for i = 1:length(data)
    ncdata[i] = NCDatasets.nc_vlen_t{T}(length(data[i]), pointer(data[i]))
end

varname = "varname"
vlentypename = "name-vlen"

ncid = NCDatasets.nc_create(filename,NCDatasets.NC_CLOBBER | NCDatasets.NC_NETCDF4)

dimid = NCDatasets.nc_def_dim(ncid, "casts", dimlen)

typeid = NCDatasets.nc_def_vlen(ncid, vlentypename, NCDatasets.ncType[T])
varid = NCDatasets.nc_def_var(ncid, varname, typeid, [dimid])


for i = 1:dimlen
    NCDatasets.nc_put_var1(ncid, varid, [i-1], data[i])
end

typeids = NCDatasets.nc_inq_typeids(ncid)
typeid = typeids[1]
name2,datum_size2,base_nc_type2 = NCDatasets.nc_inq_vlen(ncid,typeid)

@test name2 == vlentypename
@test NCDatasets.jlType[base_nc_type2] == T

NCDatasets.nc_close(ncid)


# Reopen

ncid = NCDatasets.nc_open(filename,NCDatasets.NC_NOWRITE)

varid = NCDatasets.nc_inq_varid(ncid,varname)

typeids = NCDatasets.nc_inq_typeids(ncid)
#@show typeids

xtype = NCDatasets.nc_inq_vartype(ncid,varid)

@test xtype == typeids[1]

if xtype >= NCDatasets.NC_FIRSTUSERTYPEID
    #@show xtype,NCDatasets.NC_VLEN

    typename,shape,base_nc_type,numfields,class = NCDatasets.nc_inq_user_type(ncid,xtype)

    #@show typename,shape,base_nc_type,numfields,class
    @test base_nc_type == NCDatasets.NC_INT

    T2 = NCDatasets.jlType[base_nc_type]

    @test T == T2
    if class == NCDatasets.NC_VLEN
        data2 = Vector{Vector{T}}(undef,dimlen)
        NCDatasets.nc_get_var!(ncid,varid,data2)
        @test data == data2

        for i = 1:dimlen
            tmp2 = NCDatasets.nc_get_var1(Vector{T},ncid,varid,[i-1])
            @test data[i] == tmp2
        end
    end
end

NCDatasets.nc_close(ncid)
