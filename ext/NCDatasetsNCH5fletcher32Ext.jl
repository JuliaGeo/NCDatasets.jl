module NCDatasetsNCH5fletcher32Ext
using NCDatasets
using NCH5fletcher32_jll

function __init__()
    NCDatasets.register_plugin_dir!("fletcher32", dirname(NCH5fletcher32_jll.lib__nch5fletcher32))
end

end
