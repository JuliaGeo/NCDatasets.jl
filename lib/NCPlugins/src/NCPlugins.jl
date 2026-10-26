"""
    NCPlugins

Convenience package which makes the NetCDF filter plugins available to NCDatasets:
the compression filters blosc, bzip2 and zstd, and the plugins which are used by
NCZarr (deflate, shuffle, fletcher32, szip and the NCZarr codec libraries).

```julia
using NCDatasets, NCPlugins
```

Loading this package loads the plugin JLLs (`NCH5blosc_jll`, `NCH5bzip2_jll`,
`NCH5zstd_jll`, `NCH5deflate_jll`, `NCH5shuffle_jll`, `NCH5fletcher32_jll`,
`NCH5szip_jll`, `NCZhdf5filters_jll` and `NCZstdfilters_jll`), which activates the corresponding package extensions of
NCDatasets, and then passes the plugin directories to netcdf-c. Which plugins
are used is controlled by the Preferences.jl key `"plugins"` of NCDatasets (see
`NCDatasets.enabled_plugins`). This package exports nothing.
"""
module NCPlugins

using NCDatasets
# The JLLs trigger the NCDatasets package extensions which register
# the plugin directories.
import NCH5blosc_jll
import NCH5bzip2_jll
import NCH5zstd_jll
import NCH5deflate_jll
import NCH5shuffle_jll
import NCH5fletcher32_jll
import NCH5szip_jll
import NCZhdf5filters_jll
import NCZstdfilters_jll

function __init__()
    NCDatasets.load_plugins!()
end

end
