module NCDatasetsNCH5shuffleExt
using NCDatasets
using NCH5shuffle_jll

function __init__()
    NCDatasets.register_plugin_dir!("shuffle", dirname(NCH5shuffle_jll.lib__nch5shuffle))
end

end
