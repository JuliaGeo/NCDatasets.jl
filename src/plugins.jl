
struct NCPluginPath <: AbstractVector{String}
end


"""
    NCDatasets.PLUGIN_PATH

Directories containing HDF5 and NCZarr plugins can be added to the
NetCDF search path via `NCDatasets.PLUGIN_PATH`:

```julia
push!(NCDatasets.PLUGIN_PATH,"/some/plugin/dir") # or pushfirst!
```

Unfortunately, modifing the HDF5 plugins path indepenently of the NetCDF-C library is
currently unsupported and leads to an assertion failure in the C library
(https://github.com/Unidata/netcdf-c/issues/3478).

Once a plugin has been *used* to encode/decode any variable, attempting to
unregistering it via removing it from
`NCDatasets.PLUGIN_PATH` does not have any effect.
"""
const PLUGIN_PATH = NCPluginPath()
const PLUGIN_PATH_LOCK = ReentrantLock()

import Base: append!, push!, deleteat!, delete!, size, getindex, collect, IndexStyle
Base.size(::NCPluginPath) = (Int(nc_plugin_path_ndirs()),)
Base.getindex(::NCPluginPath,i) = nc_plugin_path_get()[i]
Base.collect(::NCPluginPath) = nc_plugin_path_get()
Base.IndexStyle(::NCPluginPath) = IndexLinear()


# once a plugin is used once, changing the plugin path does not unload it
for fun in (:append!, :deleteat!, :empty!, :insert!, :keepat!, :pop!, :popat!,
            :popfirst!, :prepend!, :push!, :pushfirst!, :replace!, :splice!,
            :setindex!)
    @eval function Base.$(fun)(::NCPluginPath,args...)
        lock(PLUGIN_PATH_LOCK) do
            dirs = nc_plugin_path_get()
            ret = $fun(dirs,args...)
            nc_plugin_path_set!(dirs)
            return ret
        end
    end
end

const DEFAULT_PLUGINS = [
    NCH5blosc_jll,
    NCH5bzip2_jll,
    NCH5deflate_jll,
    NCH5fletcher32_jll,
    NCH5shuffle_jll,
    NCH5szip_jll,
    NCH5zstd_jll,
    NCZhdf5filters_jll,
    NCZstdfilters_jll,
]

function plugins_toload()
    plugins_preference = Preferences.load_preference(NCDatasets,"plugins","all")

    return [f for f in DEFAULT_PLUGINS if (plugins_preference == "all" || (replace(string(f),"_jll" => "") in plugins_preference))]

end


"""
    NCDatasets.register_plugins!()

Register default HDF5 and NCZarr plugin filters distributed with the NetCDF
library. Currently the default plugins are the
following packages:

  *  $(join(string.('`',DEFAULT_PLUGINS,'`'),"\n * "))


"""
function register_plugins!(p = plugins_toload())
    dirs = [dirname(getproperty(f,Symbol("lib__" * lowercase(replace(string(f),"_jll" => ""))))) for f in p]

    if length(dirs) == 0
        # safer to not use nc_plugin_path_get/nc_plugin_path_set at all in this case
        # https://github.com/Unidata/netcdf-c/issues/3478
        return nothing
    end

    lock(PLUGIN_PATH_LOCK) do
        dirs = setdiff(dirs,PLUGIN_PATH)

        if length(dirs) == 0
            return nothing
        end

        @debug "append dirs to NetCDF plugin path " dirs
        append!(PLUGIN_PATH,dirs)

        @debug "reg ",length(PLUGIN_PATH), getpid()
    end

    return nothing
end

VERSION >= v"1.11.0-DEV.469" && eval(Meta.parse("public PLUGIN_PATH"))
