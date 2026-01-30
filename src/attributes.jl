# `Attributes` is a collection of name and value pairs.
# Dataset (including groups) and variables can have attributes.

# Return all attribute names
function listAtt(ncid,varid)
    natts = nc_inq_varnatts(ncid,varid)
    names = Vector{String}(undef,natts)

    for attnum = 0:natts-1
        names[attnum+1] = nc_inq_attname(ncid,varid,attnum)
    end

    return names
end


# helper function to treat Dataset and Variable uniformly

_ncid(ds::Dataset) = ds.ncid
_varid(ds::Dataset) = NC_GLOBAL
_dataset(ds::Dataset) = ds

_ncid(v::Variable) = v.ds.ncid
_varid(v::Variable) = v.varid
_dataset(v::Variable) = v.ds



"""
    attribnames(ds::Union{Dataset,Variable})

Return a list of the names of all attributes. Generally the attributes are loaded
using the `attrib` property of NetCDF datasets and variables:

```julia
ds = NCDataset("file.nc")
all_attribute_names = keys(ds.attrib)
```
"""
attribnames(ds::Union{Dataset,Variable}) = listAtt(_ncid(ds),_varid(ds))


"""
    attrib(ds::Union{Dataset,Variable},name::SymbolOrString)

Return the value of the attribute called `name` from the
attribute list `a`. Generally the attributes are loaded by
indexing, for example:

```julia
ds = NCDataset("file.nc")
title = ds.attrib["title"]
```
"""
attrib(ds::Union{Dataset,Variable},name::SymbolOrString) = nc_get_att(_ncid(ds),_varid(ds),name)



"""
    defAttrib(ds::Union{Dataset,Variable},name::SymbolOrString,data)

Set the attribute called `name` to the value `data` in the
attribute list `a`. `data` can be a vector or a scalar. A scalar
is handeld as a vector with one element in the NetCDF data model.

Generally the attributes are defined by indexing, for example:

```julia
ds = NCDataset("file.nc","c")
ds.attrib["title"] = "my title"
close(ds)
```

If `data` is a string, then attribute is saved as a list of
NetCDF characters (`NC_CHAR`) with the appropriate length. To save the attribute
as a string (`NC_STRING`) you can use the following:

```julia
ds = NCDataset("file.nc","c")
ds.attrib["title"] = ["my title"]
close(ds)
"""
function defAttrib(ds::Union{Dataset,Variable},name::SymbolOrString,data)
    # make sure that the file is in define mode
    defmode(_dataset(ds)) do
        return nc_put_att(_ncid(ds),_varid(ds),name,data)
    end
end


"""
    Base.haskey(a::Attributes,name::SymbolOrString)

Check if `name` is an attribute
"""
Base.haskey(a::CommonDataModel.Attributes{<:Union{Dataset,Variable}},name::SymbolOrString) =
    _nc_has_att(_ncid(a.ds),_varid(a.ds),name)


"""
    delAttrib(ds::Union{Dataset,Variable},name::SymbolOrString)

Delete the attribute `name` in the dataset or variable.
"""
function delAttrib(ds::Union{Dataset,Variable},name::SymbolOrString)
    # make sure that the file is in define mode
    defmode(_dataset(ds)) do
        nc_del_att(_ncid(ds),_varid(ds),name)
    end
    return nothing
end
