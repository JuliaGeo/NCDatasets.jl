using MPI
using NCDatasets
using Test

nprocs = 4
prog = joinpath(@__DIR__, "test_mpi_script.jl")
fn = tempname()

run(`$(mpiexec()) -n $nprocs $(Base.julia_cmd()) --startup-file=no $prog $fn`)
# run with raise an error if prog fails

ds = NCDataset(fn)
@test ds.dim["lat"] == nprocs
@test ds["temp"][:,:] == repeat((0:(nprocs-1))',inner=(10,1))
close(ds)
