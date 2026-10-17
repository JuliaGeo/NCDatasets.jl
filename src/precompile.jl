@setup_workload begin
    # skip the workload on platforms where libnetcdf is not available
    if NetCDF_jll.is_available()
        fname = tempname() * ".nc"
        @compile_workload begin
            ds = NCDataset(fname, "c")
            defDim(ds, "lon", 3)
            defDim(ds, "lat", 2)
            for T in (Float32, Float64, Int32)
                v = defVar(ds, "var_$T", T, ("lon", "lat"),
                           attrib = ["units" => "m", "_FillValue" => T(-9999)])
                v[:, :] = ones(T, 3, 2)
                v[1, 1] = zero(T)
            end
            defVar(ds, "data", rand(3, 2), ("lon", "lat"))
            defVar(ds, "time", [DateTime(2000, 1, 1), DateTime(2000, 1, 2)], ("time",),
                   attrib = ["units" => "days since 2000-01-01"])
            ds.attrib["title"] = "precompile"
            close(ds)

            ds = NCDataset(fname)
            for T in (Float32, Float64, Int32)
                v = ds["var_$T"]
                v[:, :]
                v[1, :]
                v.var[:, :]
                v.attrib["units"]
            end
            ds["time"][:]
            ds[:data][:, :]
            keys(ds)
            ds.dim["lon"]
            show(devnull, MIME"text/plain"(), ds)
            show(devnull, MIME"text/plain"(), ds["var_Float32"])
            close(ds)
            rm(fname; force = true)
        end
    end
end
