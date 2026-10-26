module NCDatasetsNCH5zstdExt
using NCDatasets
using NCH5zstd_jll

function __init__()
    NCDatasets.register_plugin_dir!("zstd", dirname(NCH5zstd_jll.lib__nch5zstd))
end

end
