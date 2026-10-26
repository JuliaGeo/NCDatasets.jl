module NCDatasetsNCH5deflateExt
using NCDatasets
using NCH5deflate_jll

function __init__()
    NCDatasets.register_plugin_dir!("deflate", dirname(NCH5deflate_jll.lib__nch5deflate))
end

end
