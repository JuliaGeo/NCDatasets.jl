############################################################
# Filter plugin loading
#
# Package extensions (one per plugin JLL, see ext/) register the directory of
# their plugin with `register_plugin_dir!`. The registered directories are
# handed to netcdf-c with `nc_plugin_path_set` by `load_plugins!`, which the
# user calls explicitly (or implicitly by loading NCPlugins).
#
# Which plugins are registered is controlled by the Preferences.jl key
# "plugins" of NCDatasets (a list of plugin names, or "all").
############################################################

# Names of the plugins which can be registered. The name is the
# one used in the "plugins" preference.
const PLUGIN_NAMES = ("blosc", "bzip2", "zstd",
                      "deflate", "shuffle", "fletcher32", "szip",
                      "zhdf5filters", "zstdfilters")

# Loading a plugin JLL is already an explicit choice, so all plugins are
# enabled by default. The preference can be used to exclude some.
const DEFAULT_PLUGINS = collect(PLUGIN_NAMES)

# Directories of the registered plugins (in registration order)
const PLUGIN_DIRS = OrderedDict{String,String}()

# Number of registrations, and the number of registrations already passed on to
# netcdf-c. Used to make `load_plugins!` idempotent.
const PLUGIN_GEN = Ref(0)
const APPLIED_GEN = Ref(0)

# Directories handed to netcdf-c by the last call to `load_plugins!`
const APPLIED_DIRS = String[]

# Non-default directories of the plugin path which were kept (and warned about)
const KEPT_DIRS = String[]

# Plugin path of a netcdf-c which is not configured by the user
# (the BinaryBuilder build prefix of NetCDF_jll and the system-wide location)
const BUILTIN_PLUGIN_DIRS = ["/workspace/destdir/hdf5/lib/plugin",
                             "/usr/local/hdf5/lib/plugin"]

struct NCPluginList
    ndirs::Csize_t
    dirs::Ptr{Ptr{Cchar}}
end

"""
    NCDatasets.enabled_plugins()

Return the names of the plugins which are allowed to be loaded: the
Preferences.jl key `"plugins"` of NCDatasets (default: all plugins in `$(PLUGIN_NAMES)`).
The value `"all"` also enables all plugins.

```julia
using Preferences, NCDatasets
set_preferences!(NCDatasets, "plugins" => ["zstd", "blosc"])
```

The preference is read when the plugin JLLs are loaded, i.e. a Julia restart is
required after changing it.
"""
function enabled_plugins()
    names = load_preference(NCDatasets, "plugins", DEFAULT_PLUGINS)
    names = names isa AbstractString ? [names] : collect(String, names)
    "all" in names && return collect(PLUGIN_NAMES)
    return names
end

"""
    NCDatasets.register_plugin_dir!(name::AbstractString, dir::AbstractString)

Register the directory `dir` containing the filter plugin `name` (one of
`$(PLUGIN_NAMES)`). The directory is ignored if the plugin is not enabled in
`NCDatasets.enabled_plugins()`. Returns `true` if the directory was registered.

This is called by the package extensions of NCDatasets for the plugin JLLs. The
registered directories are passed on to netcdf-c by [`NCDatasets.load_plugins!`](@ref).
"""
function register_plugin_dir!(name::AbstractString, dir::AbstractString)
    name in enabled_plugins() || return false
    if !isdir(dir)
        @warn "Plugin directory $dir of the NetCDF plugin $name does not exist"
        return false
    end
    lock(NETCDF_LOCK) do
        if get(PLUGIN_DIRS, name, nothing) != dir
            PLUGIN_DIRS[name] = dir
            PLUGIN_GEN[] += 1
        end
    end
    return true
end

"""
    NCDatasets.plugin_dirs()

Directories of the plugins registered so far.
"""
plugin_dirs() = collect(values(PLUGIN_DIRS))

function plugin_path_symbols()
    h = Libdl.dlopen(libnetcdf)
    syms = map((:nc_initialize, :nc_plugin_path_get, :nc_plugin_path_set,
                :ncaux_plugin_path_clear)) do s
        Libdl.dlsym(h, s; throw_error = false)
    end
    return syms
end

# Current plugin path of netcdf-c. netcdf-c must be initialized.
function get_plugin_path(reclaim)
    pl = Ref(NCPluginList(0, C_NULL))
    code = ccall((:nc_plugin_path_get, libnetcdf), Cint, (Ptr{NCPluginList},), pl)
    check(code)
    dirs = [unsafe_string(unsafe_load(pl[].dirs, i)) for i in 1:Int(pl[].ndirs)]
    if reclaim !== nothing
        ccall((:ncaux_plugin_path_clear, libnetcdf), Cint, (Ptr{NCPluginList},), pl)
    end
    return dirs
end

function set_plugin_path(dirs::Vector{String})
    cdirs = [Base.unsafe_convert(Cstring, d) for d in dirs]
    GC.@preserve dirs cdirs begin
        pl = Ref(NCPluginList(length(dirs), Ptr{Ptr{Cchar}}(pointer(cdirs))))
        check(ccall((:nc_plugin_path_set, libnetcdf), Cint, (Ptr{NCPluginList},), pl))
    end
end

"""
    NCDatasets.load_plugins!() -> Bool

Make the filter plugins registered by the package extensions of NCDatasets
available to netcdf-c. Returns `true` if the plugin path of netcdf-c contains the
registered plugin directories.

This function initializes netcdf-c, merges the registered directories in front of
the current plugin path of netcdf-c (e.g. from the environment variable
`HDF5_PLUGIN_PATH`) and sets the result with `nc_plugin_path_set`. A warning is
issued if the current plugin path was changed by somebody else than NCDatasets;
those directories are kept.

It is not called automatically when a dataset is opened: call it after loading
the plugin JLLs and before opening files which need them, or load the
`NCPlugins` package, which does this on initialization. Calling it again after
loading further plugin JLLs adds their directories.
"""
function load_plugins!()
    lock(NETCDF_LOCK) do
        APPLIED_GEN[] == PLUGIN_GEN[] && return !isempty(APPLIED_DIRS)
        gen = PLUGIN_GEN[]
        # do not retry (and warn again) for the same registrations
        APPLIED_GEN[] = gen

        init, get_, set_, reclaim = plugin_path_symbols()

        if init === nothing || get_ === nothing || set_ === nothing
            @warn "The NetCDF library $libnetcdf does not provide nc_plugin_path_set " *
                "(NetCDF 4.9.3 or later is required). " *
                "The plugins $(collect(keys(PLUGIN_DIRS))) cannot be loaded; " *
                "set the environment variable HDF5_PLUGIN_PATH before starting Julia instead."
            return false
        end

        # nc_plugin_path_get and nc_plugin_path_set abort the process
        # if netcdf-c is not initialized
        check(ccall(init, Cint, ()))

        current = get_plugin_path(reclaim)
        # directories which are not ours or from a previous call
        others = filter(d -> d ∉ APPLIED_DIRS, current)
        if !issubset(others, BUILTIN_PLUGIN_DIRS) && others != KEPT_DIRS
            @warn "The plugin path of netcdf-c is not the default: $current. " *
                "These directories are kept after the directories of the NCDatasets plugins."
        end

        empty!(KEPT_DIRS)
        append!(KEPT_DIRS, others)

        dirs = unique(vcat(plugin_dirs(), others))
        set_plugin_path(dirs)
        empty!(APPLIED_DIRS)
        append!(APPLIED_DIRS, plugin_dirs())
        return true
    end
end

############################################################
# Hint for missing filter plugins
############################################################

const NC_ENOFILTER = -136 # Filter not defined on variable

# Filters for which the plugins can be loaded with NCPlugins
const NCPLUGINS_FILTERS = Dict(307 => "bzip2", 32001 => "blosc", 32015 => "zstd")

# Ids of the filters of a variable which are not available
# (e.g. because the plugin is not loaded)
function unavailable_filters(ncid, varid)
    nfilters = Ref(Csize_t(0))
    check(ccall((:nc_inq_var_filter_ids, libnetcdf), Cint,
                (Cint, Cint, Ptr{Csize_t}, Ptr{Cuint}), ncid, varid, nfilters, C_NULL))
    ids = Vector{Cuint}(undef, nfilters[])
    check(ccall((:nc_inq_var_filter_ids, libnetcdf), Cint,
                (Cint, Cint, Ptr{Csize_t}, Ptr{Cuint}), ncid, varid, nfilters, ids))
    return filter(id -> ccall((:nc_inq_filter_avail, libnetcdf), Cint,
                              (Cint, Cuint), ncid, id) == NC_ENOFILTER, ids)
end

function filter_hint(ids)
    list = join(("$id" * (haskey(NCPLUGINS_FILTERS, id) ? " ($(NCPLUGINS_FILTERS[id]))" : "")
                 for id in ids), ", ")
    msg = "The variable uses the filter(s) $list which are not available."
    if all(in(keys(NCPLUGINS_FILTERS)), ids)
        msg *= " The plugins can be loaded with `using NCPlugins`."
    end
    return msg
end

# Run `f()`. If it fails with NC_ENOFILTER because a filter of the variable
# is not available, the error is extended with a hint how to load the plugin.
# NC_ENOFILTER has other causes in netcdf-c, in which case the error is rethrown unchanged.
function with_filter_hint(f, ncid, varid)
    try
        return f()
    catch err
        if err isa NetCDFError && err.code == NC_ENOFILTER
            ids = try
                lock(NETCDF_LOCK) do
                    unavailable_filters(ncid, varid)
                end
            catch
                Cuint[]
            end
            isempty(ids) || throw(NetCDFError(err.code, err.msg * ". " * filter_hint(ids)))
        end
        rethrow()
    end
end
