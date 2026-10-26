module NCDatasetsNCH5bloscExt
using NCDatasets
using NCH5blosc_jll

function __init__()
    NCDatasets.register_plugin_dir!("blosc", dirname(NCH5blosc_jll.lib__nch5blosc))
end

end
