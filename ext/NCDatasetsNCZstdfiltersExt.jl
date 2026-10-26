module NCDatasetsNCZstdfiltersExt
using NCDatasets
using NCZstdfilters_jll

function __init__()
    NCDatasets.register_plugin_dir!("zstdfilters", dirname(NCZstdfilters_jll.lib__nczstdfilters))
end

end
