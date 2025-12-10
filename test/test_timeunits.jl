# convertion of time units
using Test
using Dates
using NCDatasets
using DataStructures

filename = tempname()

for (timeunit,factor) in [("days",1),("hours",24),("minutes",24*60),("seconds",24*60*60)]

    NCDataset(filename,"c") do ds
        defDim(ds,"time",3)
        v = defVar(ds,"time",Float64,("time",), attrib = [
            "units" => "$(timeunit) since 2000-01-01 00:00:00"])
        v[:] = [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)]
        #v.var[:] = [1.,2.,3.]

        # write "scalar" value
        v[3] = DateTime(2000,1,5)
        @test v[3] == DateTime(2000,1,5)

        # time origin
        v[3] = 0
        @test v[3] == DateTime(2000,1,1)
    end

    NCDataset(filename,"r") do ds
        v2 = ds["time"].var[:]
        @test v2[1] == 1. * factor

        v2 = ds["time"][:]
        @test v2[1] == DateTime(2000,1,2)
    end

    rm(filename)
end

NCDataset(filename,"c") do ds
    defDim(ds,"time",3)

    v2 = defVar(ds,"time2",
                           [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)],("time",), attrib = [
                               "units" => NCDatasets.CFTime.DEFAULT_TIME_UNITS
                           ])

    @test v2[:] == [DateTime(2000,1,2), DateTime(2000,1,3), DateTime(2000,1,4)]
    @test v2.attrib["units"] == NCDatasets.CFTime.DEFAULT_TIME_UNITS
end


# test fill-value in time axis
filename = tempname()
NCDataset(filename,"c") do ds
    defDim(ds,"time",3)
    v = defVar(ds,"time",Float64,("time",), attrib = [
        "units" => "days since 2000-01-01 00:00:00",
        "_FillValue" => -99999.])
    v[:] = [DateTime(2000,1,2), DateTime(2000,1,3), missing]
    # load a "scalar" value
    @test v[1] == DateTime(2000,1,2)
end
rm(filename)


# test fill-value in time axis
filename = tempname()
NCDataset(filename,"c") do ds
    defDim(ds,"time",3)
    v = defVar(ds,"time",Float64,("time",), attrib = [
        "units" => "days since 2000-01-01 00:00:00",
        "_FillValue" => -99999.])
    v[:] = [1.,2.,3.]
    # load a "scalar" value
    @test v[1] == DateTime(2000,1,2)
end
rm(filename)


# test non-standard calendars
filename = tempname()
NCDataset(filename,"c") do ds
    defDim(ds,"time",3)
    v = @test_logs (:warn,r".*bogous_calendar.*") defVar(ds,"time",Float64,("time",), attrib = [
        "units" => "days since 2000-01-01 00:00:00",
        "calendar" => "bogous_calendar"])
    v.var[:] = [1.,2.,3.]
    # load a "scalar" value
    @test v[1] == 1.
end
rm(filename)


# test Float32 to Float64 promotion to avoid rounding issues
# issue 177

filename = tempname()
ds = NCDataset(filename,"c")
defDim(ds,"time",1)
nctime = defVar(ds,"time",Float32,("time",), attrib = OrderedDict(
    "units" => "days since 1950-01-01 00:00:00"))
nctime[1] = DateTime(2014,1,1)

@test nctime[1] == DateTime(2014,1,1)
close(ds)

# issue 181
filename = tempname()
ds = NCDataset(filename,"c")
defDim(ds,"time",1)
ncvar = @test_logs (:warn,r".*not_a_unit.*") begin
    defVar(ds,"time",Float32,("time",), attrib = OrderedDict(
        "units" => "not_a_unit since 1950-01-01 00:00:00"))
end
@test eltype(ncvar) == Float32
close(ds)


# issue 291
using Dates
filename = tempname()
ds = NCDataset(filename,"c");
ncv = defVar(ds,"data",Date(2000):Month(1):Date(2001), ("time",))
@test ncv[:] == Date(2000):Month(1):Date(2001)
close(ds)
