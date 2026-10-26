module NCDatasetsNCH5bzip2Ext
using NCDatasets
using NCH5bzip2_jll

function __init__()
    NCDatasets.register_plugin_dir!("bzip2", dirname(NCH5bzip2_jll.lib__nch5bzip2))
end

end
