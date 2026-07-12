
struct NcEnumVariable{V, N, R, TDS}  <: AbstractCategoricalVariable{V, N, R}
    data_var::Variable{R, N, TDS} 
end

## handle DiskArray API
getvaluearray(a::NcEnumVariable) = a.data_var

function getmapping(a::NcEnumVariable)
    v = getvaluearray(a)
    name, xtype, ndims, dimids, natts = raw_nc_inq_var(v.ds.ncid,v.varid)
    name, mapping = get_nc_enum_meta(v.ds.ncid, xtype)
    return mapping
end
