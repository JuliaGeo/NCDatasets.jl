# Dimension is a name tag for the size of an array along a given dimension
# A dimension can be unlimited.


function dimnames(ds::NCDataset)
    return String[nc_inq_dimname(ds.ncid,dimid)
                  for dimid in nc_inq_dimids(ds.ncid,false)]
end

function dim(ds::NCDataset,name::SymbolOrString)
    dimid = nc_inq_dimid(ds.ncid,name)
    return nc_inq_dimlen(ds.ncid,dimid)
end


function unlimited(ds::NCDataset)
    return String[nc_inq_dimname(ds.ncid,dimid)
                  for dimid in nc_inq_unlimdims(ds.ncid)]
end


export unlimited

"""
    defDim(ds::NCDataset,name,len)

Define a dimension in the data set `ds` with the given `name` and length `len`.
If `len` is the special value `Inf`, then the dimension is considered as
`unlimited`, i.e. it will grow as data is added to the NetCDF file.

For example:

```julia
using NCDatasets
ds = NCDataset("/tmp/test.nc","c")
defDim(ds,"lon",100)
# [...]
close(ds)
```

This defines the dimension `lon` with the size 100.

To create a variable with an unlimited dimensions use for example:

```julia
using NCDatasets
ds = NCDataset("/tmp/test2.nc","c")
defDim(ds,"lon",10)
defDim(ds,"lat",10)
defDim(ds,"time",Inf)
defVar(ds,"unlimited_variable",Float64,("lon","lat","time"))
@show ds.dim["time"]
# returns 0 as no data is added
ds["unlimited_variable"][:,:,1:4] = randn(10,10,4)
@show ds.dim["time"]
# returns now 4 as 4 time slice have been added
close(ds)
```
"""
function defDim(ds::NCDataset,name::SymbolOrString,len)
    # make sure that the file is in define mode
    defmode(ds) do
        dimid = nc_def_dim(ds.ncid,name,(isinf(len) ? NC_UNLIMITED : len))
    end
    return nothing
end
export defDim

"""
    renameDim(ds::NCDataset,oldname::SymbolOrString,newname::SymbolOrString)

Renames the dimenion `oldname` in the dataset `ds` with the name `newname`.
"""
function renameDim(ds::NCDataset,oldname::SymbolOrString,newname::SymbolOrString)
    # make sure that the file is in define mode
    defmode(ds) do
        dimid = nc_inq_dimid(ds.ncid,oldname)
        nc_rename_dim(ds.ncid,dimid,newname)
    end
    return nothing
end
export renameDim
