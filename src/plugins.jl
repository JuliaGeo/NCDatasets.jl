
struct NCPluginPath <: AbstractVector{String}
end
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

const DEFAULT_FILTERS = [
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
    plugins_preference = Preferences.load_preference(NCDatasets,"plugins",["all"])
    @show plugins_preference

    return [f for f in DEFAULT_FILTERS if (replace(string(f),"_jll" => "") in plugins_preference ||
                    plugins_preference == ["all"])]

end

function register_filters(p = plugins_toload())
    @show p
    dirs = [dirname(getproperty(f,Symbol("lib__" * lowercase(replace(string(f),"_jll" => ""))))) for f in p]

    @info "append dirs to NetCDF plugin path " dirs
    append!(PLUGIN_PATH,dirs)
end
