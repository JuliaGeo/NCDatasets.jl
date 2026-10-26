module NCDatasetsNCZhdf5filtersExt
using NCDatasets
using NCZhdf5filters_jll

function __init__()
    NCDatasets.register_plugin_dir!("zhdf5filters", dirname(NCZhdf5filters_jll.lib__nczhdf5filters))
end

end
