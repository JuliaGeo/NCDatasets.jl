"""
    escape(val)

Escape backslash, dollar and quote from string `val`.
"""
function escape(val)
     valescaped = val
     # backslash must come first
     for c in ['\\','$','"']
        valescaped = replace(valescaped,c => "\\$c")
    end
	return valescaped
end

"""
    escape(val)

Escape string for variable names.
"""
function escapevar(val)
    return replace(val," " => "_", "-" => "_")
end

function ncgen(io::IO,fname; newfname = "filename.nc")
    ds = NCDataset(fname)
    unlimited_dims = unlimited(ds.dim)
    print(io,"using NCDatasets, DataStructures\n")
    print(io,"ds = NCDataset(\"$(escape(newfname))\",\"c\"")
    ncgen_setattrib(io,ds.attrib)
    print(io,")\n\n")

    print(io,"# Dimensions\n\n")
    for (d,v) in ds.dim
        if d in unlimited_dims
            print(io,"ds.dim[\"$d\"] = Inf # unlimited dimension\n")
        else
            print(io,"ds.dim[\"$d\"] = $v\n")
        end
    end

    print(io,"\n# Declare variables\n\n")

    for (d,v) in ds
        print(io,"nc$(escapevar(d)) = defVar(ds,\"$d\", $(eltype(v.var)), $(dimnames(v))")
        ncgen_setattrib(io,v.attrib)
        print(io,")\n\n")
    end

    print(io,"\n# Define variables\n\n")

    for (d,v) in ds
        dims = join(fill(':',ndims(v)),',')
        print(io,"# nc$(escapevar(d))[$dims] = ...\n")
    end

    print(io,"\nclose(ds)\n")
    close(ds)
end


"""
    ncgen(fname; ...)
    ncgen(fname,jlname; ...)

Generate the Julia code that would produce a NetCDF file with the same metadata
as the NetCDF file `fname`. The code is placed in the file `jlname` or printed
to the standard output. By default the new NetCDF file is called `filename.nc`.
This can be changed with the optional parameter `newfname`.
"""
ncgen(fname; kwargs...)  = ncgen(stdout,fname; kwargs...)

function ncgen(fname,jlname; kwargs...)
    open(jlname,"w") do io
        ncgen(io, fname; kwargs...)
    end
end
export ncgen

litteral(val::String) = "\"$(escape(val))\""
litteral(val::Float64) = val
litteral(val::Number) = "$(eltype(val))($(val))"
litteral(val) = "$(val)" # for arrays

function ncgen_setattrib(io,attrib)
    if length(attrib) == 0
        return
    end

    print(io,", attrib = OrderedDict(\n")

    for (d,val) in attrib
        litval = litteral(val)
        print(io,"    \"$d\"" * (" "^max(0,(25-length(d)))) * " => $litval,\n");
    end
    print(io,")")

end
