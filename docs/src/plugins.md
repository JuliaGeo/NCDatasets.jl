# Filter plugins

NetCDF-4 files can use compression filters which are not built into netcdf-c,
such as blosc, bzip2 and zstd. These filters are provided by plugins which
netcdf-c searches for in its *plugin path*. The plugins are available as
Julia packages (`NCH5blosc_jll`, `NCH5bzip2_jll`, `NCH5zstd_jll`, ...).

## Usage

The simplest way is to load the convenience package `NCPlugins`, which
loads all plugin JLLs (blosc, bzip2, zstd and the plugins for NCZarr):

```julia
using NCDatasets, NCPlugins
```

Alternatively, load the plugin JLLs directly. NCDatasets registers the directory
of every loaded plugin JLL (via package extensions); passing the directories to
netcdf-c has to be requested explicitly, before opening files which need the plugins:

```julia
using NCDatasets, NCH5zstd_jll
NCDatasets.load_plugins!()
```

`load_plugins!` can be called again after loading more plugin JLLs.

Files using a filter whose plugin is not loaded can be opened, but reading (or writing)
the data of a variable using this filter fails with `NetCDF: Filter error: undefined filter encountered`.
If the filter is one of blosc, bzip2 or zstd, the error message suggests `using NCPlugins`.

Deflate (zlib), shuffle, fletcher32 and szip are built into HDF5 and need no plugin
for NetCDF-4/HDF5 files. Their plugins (`NCH5deflate_jll`, `NCH5shuffle_jll`,
`NCH5fletcher32_jll`, `NCH5szip_jll`) and the codec libraries
`NCZhdf5filters_jll` and `NCZstdfilters_jll` are used by NCZarr stores
(`mode=nczarr` in the URL). NCZarr needs both a filter plugin and a codec library: for
zstd, bzip2 and blosc this is `NCH5zstd_jll` (etc.) together with `NCZstdfilters_jll`,
and for deflate, shuffle, fletcher32 and szip it is the `NCH5*` plugin together with
`NCZhdf5filters_jll`. With a filter plugin but without its codec library, defining a filter on a variable of
such a store (for example `defVar(ds, name, T, dims; deflatelevel = 5)`) crashes Julia with a
segmentation fault (netcdf-c 4.10.1), and reading fails with
`Variable has unsupported codec`. Loading `NCPlugins` loads both and avoids this.

## Selecting plugins

The Preferences.jl key `"plugins"` of NCDatasets lists the plugins which are
used when their JLL is loaded. The default is to use all of them. The
available names are `blosc`, `bzip2`, `zstd`, `deflate`, `shuffle`, `fletcher32`,
`szip`, `zhdf5filters` and `zstdfilters`; `"all"` enables all of them.

```julia
using Preferences, NCDatasets
set_preferences!(NCDatasets, "plugins" => ["zstd", "zstdfilters"])
```

Julia has to be restarted for a changed preference to take effect.

## Plugin path

The plugin directories are put in front of the existing plugin path of netcdf-c
(for example from the environment variable `HDF5_PLUGIN_PATH`) and a warning is
issued if the existing path is not the default. This requires netcdf-c 4.9.3 or
later (`nc_plugin_path_set`); otherwise a warning is issued and the plugins have to be
found via `HDF5_PLUGIN_PATH`.

## Interaction with HDF5.jl

NCDatasets (through `NetCDF_jll`) and HDF5.jl use the same HDF5 library (`HDF5_jll`) when
both are installed from the General registry. HDF5 keeps a single, process-wide plugin
path, which `NCDatasets.load_plugins!` sets via netcdf-c. The following was tested
with netcdf-c 4.10.1 and HDF5.jl 0.17.4:

* After `NCDatasets.load_plugins!()`, HDF5.jl can read datasets which use the loaded filters
  (e.g. zstd) without further setup, for example in files written by NCDatasets.
  Without it, HDF5.jl fails with `filter missing, filter id: 32015 name: zstd`.
* netcdf-c replaces the plugin path of HDF5 with its own list. Directories which were added
  with HDF5.jl's plugin functions (`HDF5.API.h5pl_append`, ...) *before* calling
  `load_plugins!` are removed from the plugin path.
* Do not change the plugin path with HDF5.jl *after* netcdf-c has set it (for example
  after `load_plugins!`). netcdf-c checks that its plugin path and the one of HDF5 agree and
  *aborts the process* (`Assertion failed: (l5.ndirs == nclistlength(gs->pluginpaths))`) the next
  time it reads its plugin path, which `load_plugins!` does when new plugins have been
  registered.
* To use additional plugin directories with both packages, set the environment
  variable `HDF5_PLUGIN_PATH` before starting Julia. netcdf-c puts these directories
  after the directories of the NCDatasets plugins and warns that the plugin path is not
  the default.

Not tested: filters which are implemented in Julia and registered with the HDF5 library
(the `H5Z` API) instead of being found on the plugin path. They are registered in the same
HDF5 library and are therefore expected to be usable by NCDatasets, too.

```@docs
NCDatasets.load_plugins!
NCDatasets.register_plugin_dir!
NCDatasets.enabled_plugins
NCDatasets.plugin_dirs
```
