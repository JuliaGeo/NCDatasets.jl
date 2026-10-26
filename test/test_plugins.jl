using NCDatasets
using Test

@testset "plugin registry" begin
    # no plugin JLL is needed to test the registry
    dir = mktempdir()

    # "deflate" is not enabled by default
    if !("deflate" in NCDatasets.enabled_plugins())
        @test NCDatasets.register_plugin_dir!("deflate", dir) == false
        @test !(dir in NCDatasets.plugin_dirs())
    end

    # an enabled plugin with a non-existing directory is ignored (with a warning)
    @test_logs (:warn, r"does not exist") NCDatasets.register_plugin_dir!("zstd", joinpath(dir, "missing"))

    syms = NCDatasets.plugin_path_symbols()
    if all(!isnothing, syms[1:3]) && "zstd" in NCDatasets.enabled_plugins()
        @test NCDatasets.register_plugin_dir!("zstd", dir)
        @test dir in NCDatasets.plugin_dirs()
        @test NCDatasets.load_plugins!()

        path = NCDatasets.get_plugin_path(nothing)
        @test dir in path
        # registered directories come first
        @test findfirst(==(dir), path) <= length(NCDatasets.plugin_dirs())

        # idempotent
        @test NCDatasets.load_plugins!()
        @test NCDatasets.get_plugin_path(nothing) == path
    end
end

@testset "filter hint" begin
    fname = tempname()
    NCDataset(fname, "c") do ds
        defDim(ds, "x", 3)
        v = defVar(ds, "v", Int32, ("x",))
        v[:] = [1, 2, 3]

        # NC_ENOFILTER which is not caused by a missing filter is not changed
        err = NCDatasets.NetCDFError(NCDatasets.NC_ENOFILTER, "other cause")
        e = try
            NCDatasets.with_filter_hint(ds.ncid, v.var.varid) do
                throw(err)
            end
        catch e
            e
        end
        @test e === err

        # other errors are not changed either
        e = try
            NCDatasets.with_filter_hint(ds.ncid, v.var.varid) do
                throw(ErrorException("x"))
            end
        catch e
            e
        end
        @test e isa ErrorException

        @test isempty(NCDatasets.unavailable_filters(ds.ncid, v.var.varid))
        @test v[:] == [1, 2, 3]
    end
    rm(fname)

    @test occursin("using NCPlugins", NCDatasets.filter_hint([32015, 307]))
    @test !occursin("using NCPlugins", NCDatasets.filter_hint([32015, 12345]))
    @test occursin("12345", NCDatasets.filter_hint([12345]))
end
