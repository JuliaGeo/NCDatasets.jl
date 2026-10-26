module NCDatasetsNCH5szipExt
using NCDatasets
using NCH5szip_jll

function __init__()
    NCDatasets.register_plugin_dir!("szip", dirname(NCH5szip_jll.lib__nch5szip))
end

end
