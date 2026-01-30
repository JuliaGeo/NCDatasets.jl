# Groups is a collection of dimension, variables, attributes and sub-groups.

"""
    groupnames(ds::NCDataset)

Return the names of all subgroubs of the group `ds`.
`ds` can be the root group (dataset) or a subgroub.
"""
function groupnames(ds::NCDataset)
    return String[nc_inq_grpname(ncid)
                  for ncid in nc_inq_grps(ds.ncid)]
end


"""
    group = group(ds::NCDataset,groupname::SymbolOrString)

Return the NetCDF `group` with the name `groupname`.
The group can also be accessed via the `group` property:
For example:

```julia
ds = NCDataset("results.nc", "r");
forecast_group = ds.group["forecast"]
forecast_temp = forecast_group["temperature"]
```
"""
function group(ds::NCDataset,groupname::SymbolOrString)
    grp_ncid = nc_inq_grp_ncid(ds.ncid,groupname)
    ds = NCDataset(grp_ncid,ds.iswritable,ds.isdefmode; parentdataset = ds)
    return ds
end


"""
    defGroup(ds::NCDataset,groupname; attrib = []))

Create the group with the name `groupname` in the dataset `ds`.
`attrib` is a list of attribute name and attribute value pairs (see `NCDataset`).
"""
function defGroup(ds::NCDataset,groupname::SymbolOrString; attrib = [])
    # make sure that the file is in define mode
    defmode(ds) do
        grp_ncid = nc_def_grp(ds.ncid,groupname)
        ds = NCDataset(grp_ncid,ds.iswritable,ds.isdefmode; parentdataset = ds)

        # set global attributes for group
        for (attname,attval) in attrib
            ds.attrib[attname] = attval
        end
    end
    return ds
end
export defGroup

"""
    name(ds::NCDataset)

Return the group name of the NCDataset `ds`
"""
name(ds::NCDataset) = nc_inq_grpname(ds.ncid)
groupname(ds::NCDataset) = name(ds)

export groupname


parentdataset(ds::NCDataset) = ds.parentdataset
