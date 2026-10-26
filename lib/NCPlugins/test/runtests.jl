using Test
using NCDatasets
using NCDatasets.NetCDF_jll: libnetcdf
using NCPlugins

@testset "NCPlugins" begin
    # the extensions must have been loaded and the plugin path set
    # by NCPlugins.__init__, before any dataset is opened
    @test NCDatasets.APPLIED_GEN[] == NCDatasets.PLUGIN_GEN[]
    @test Set(keys(NCDatasets.PLUGIN_DIRS)) == Set(NCDatasets.enabled_plugins()) ∩ Set(NCDatasets.PLUGIN_NAMES)
    @test length(NCDatasets.PLUGIN_DIRS) == length(NCDatasets.PLUGIN_NAMES)
    @test issubset(NCDatasets.plugin_dirs(), NCDatasets.get_plugin_path(nothing))

    # nothing is exported
    @test isempty(setdiff(names(NCPlugins), [:NCPlugins]))

    # data compressed by a plugin can be written and read back
    filters = ["bzip2" => (307, Cuint[9]),
               "zstd" => (32015, Cuint[3]),
               "blosc" => (32001, Cuint[0, 0, 0, 0, 5, 1, 1])]
    data = Int32[(i ÷ 7 + j ÷ 5) % 50 for i in 1:400, j in 1:400]
    for (name, (id, params)) in filters
        name in NCDatasets.enabled_plugins() || continue
        fname = tempname()
        NCDataset(fname, "c") do ds
            defDim(ds, "x", 400)
            defDim(ds, "y", 400)
            v = defVar(ds, "v", Int32, ("x", "y"); chunksizes = [100, 100])
            code = ccall((:nc_def_var_filter, libnetcdf), Cint,
                         (Cint, Cint, Cuint, Csize_t, Ptr{Cuint}),
                         ds.ncid, v.var.varid, id, length(params), params)
            @test code == 0
            v[:, :] = data
        end
        @test filesize(fname) < sizeof(data) ÷ 4
        NCDataset(fname) do ds
            @test ds["v"][:, :] == data
        end
        rm(fname)
    end

    # NCZarr needs the filter plugin and its codec library
    zdir = mktempdir()
    zcases = ["zstd" => (; filter = (32015, Cuint[3])),
              "deflate+shuffle" => (; deflatelevel = 5, shuffle = true),
              "fletcher32" => (; checksum = :fletcher32)]
    for (name, kw) in zcases
        url = "file://$zdir/$(replace(name, '+' => '_')).zarr#mode=nczarr,file"
        NCDataset(url, "c") do ds
            defDim(ds, "x", 400)
            defDim(ds, "y", 400)
            kwargs = Base.structdiff(kw, (; filter = nothing))
            v = defVar(ds, "v", Int32, ("x", "y"); chunksizes = [100, 100], kwargs...)
            if haskey(kw, :filter)
                id, params = kw.filter
                code = ccall((:nc_def_var_filter, libnetcdf), Cint,
                             (Cint, Cint, Cuint, Csize_t, Ptr{Cuint}),
                             ds.ncid, v.var.varid, id, length(params), params)
                @test code == 0
            end
            v[:, :] = data
        end
        NCDataset(url) do ds
            @test ds["v"][:, :] == data
        end
    end

    # A process without NCPlugins gets a hint when reading the data
    fname = tempname()
    NCDataset(fname, "c") do ds
        defDim(ds, "x", 400)
        defDim(ds, "y", 400)
        v = defVar(ds, "v", Int32, ("x", "y"); chunksizes = [100, 100])
        params = Cuint[3]
        code = ccall((:nc_def_var_filter, libnetcdf), Cint,
                     (Cint, Cint, Cuint, Csize_t, Ptr{Cuint}),
                     ds.ncid, v.var.varid, 32015, length(params), params)
        v[:, :] = data
    end
    script = """
        using NCDatasets
        ds = NCDataset($(repr(fname)))
        v = ds["v"]
        msg = try v[:, :]; "no error" catch e; sprint(showerror, e) end
        println(msg)
    """
    out = read(`$(Base.julia_cmd()) --project=$(Base.active_project()) -e $script`, String)
    @test occursin("32015 (zstd)", out)
    @test occursin("using NCPlugins", out)
    rm(fname)
end
