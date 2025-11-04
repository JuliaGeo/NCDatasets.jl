"""
    mfds = NCDataset(fnames, mode = "r"; aggdim = nothing, deferopen = true,
                  isnewdim = false,
                  constvars = [])

Opens a multi-file dataset in read-only `"r"` or append mode `"a"`. `fnames` is a
vector of file names.

Variables are aggregated over the first unlimited dimension or over
the dimension `aggdim` if specified. Variables without the dimensions `aggdim`
are not aggregated. All variables containing the dimension `aggdim` are
aggregated. The variables that do not contain the dimension `aggdim` are assumed
constant.

If variables should be aggregated over a new dimension (not present in the
NetCDF file), one should set `isnewdim` to `true`. All NetCDF files should have
the same variables, attributes and groupes. Per default, all variables will
have an additional dimension unless they are marked as constant using the
`constvars` parameter.

The append mode is only implemented when `deferopen` is `false`.
If deferopen is `false`, all files are opened at the same time.
However the operating system might limit the number of open files. In Linux,
the limit can be controled with the [command `ulimit`](https://stackoverflow.com/questions/34588/how-do-i-change-the-number-of-open-files-limit-in-linux).

All metadata (attributes and dimension length are assumed to be the same for all
NetCDF files. Otherwise reading the attribute of a multi-file dataset would be
ambiguous. An exception to this rule is the length of the dimension over which
the data is aggregated. This aggregation dimension can varify from file to file.

Setting the experimental flag `_aggdimconstant` to `true` means that the
length of the aggregation dimension is constant. This speeds up the creating of
a multi-file dataset as only the metadata of the first file has to be loaded.

Examples:

You can use [Glob.jl](https://github.com/vtjnash/Glob.jl) to make `fnames`
from a file pattern, e.g.

```julia
using NCDatasets, Glob
ds = NCDataset(glob("ERA5_monthly3D_reanalysis_*.nc"))
```

Aggregation over a new dimension:

```julia
using NCDatasets
for i = 1:3
  NCDataset("foo\$i.nc","c") do ds
    defVar(ds,"data",[10., 11., 12., 13.], ("lon",))
  end
end

ds = NCDataset(["foo\$i.nc" for i = 1:3],aggdim = "sample", isnewdim = true)
size(ds["data"])
# output
# (4, 3)
```


"""
NCDataset(fnames::AbstractArray{<:AbstractString,N}, args...; kwargs...) where N =
   MFDataset(NCDataset,fnames, args...; kwargs...)


NCDataset(ds::MFCFVariable) = dataset(ds)
