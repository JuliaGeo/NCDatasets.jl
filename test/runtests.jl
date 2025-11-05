using NCDatasets
using Test
using Dates
using Printf
using Random

println("NetCDF library: ",NCDatasets.libnetcdf)
println("NetCDF version: ",NCDatasets.nc_inq_libvers())

@testset "NCDatasets" begin
    include("test_simple.jl")
    include("test_scalar.jl")
    include("test_append.jl")
    include("test_append2.jl")
    include("test_attrib.jl")
    include("test_writevar.jl")
    include("test_check_size.jl")
    include("test_scaling.jl")
    include("test_fillvalue.jl")
    include("test_compression.jl")
    include("test_formats.jl")
    include("test_bitarray.jl")
    include("test_variable.jl")
    include("test_variable_unlim.jl")
    include("test_copyvar.jl")
    include("test_subvariable.jl")
    include("test_strings.jl")
    include("test_lowlevel.jl")
    include("test_ncgen.jl")
    include("test_varbyatt.jl")
    include("test_rename.jl")
    include("test_corner_cases.jl")
    include("test_show.jl")
    include("test_cfconventions.jl")
    include("test_coord.jl")
    include("test_bounds.jl")
    include("test_cont_ragged_array.jl")
    include("test_chunk_cache.jl")
    include("test_enum.jl")
    include("test_missing_value.jl")
    include("test_override_attrib.jl")
    include("test_memory.jl")
    include("test_https.jl")
end

@testset "NetCDF4 groups" begin
    include("test_group.jl")
    include("test_group2.jl")
    include("test_group_mode.jl")
end

@testset "Variable-length arrays" begin
    include("test_vlen_lowlevel.jl")
    include("test_vlen.jl")
end

@testset "Compound types" begin
    include("test_compound.jl")
end

@testset "Time and calendars" begin
    include("test_timeunits.jl")
end

@testset "Multi-file datasets" begin
    include("test_multifile.jl")
end

@testset "Deferred datasets" begin
    include("test_defer.jl")
end

@testset "@select macro" begin
    include("test_select.jl")
    include("test_multifile_select.jl")
end

@testset "MPI" begin
    include("test_mpi_netcdf.jl")
end
