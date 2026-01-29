# All types using in `NCDatasets`
# Note in CommonDataModel the special properties `attrib`, `dim` and `group`
# are made available.


# Exception type for error thrown by the NetCDF library
struct NetCDFError <: Exception
    code::Cint
    msg::String
end

abstract type AbstractNCDataset <: AbstractDataset
end

abstract type AbstractNCVariable{T,N} <: AbstractVariable{T,N}
end

# Variable (as stored in NetCDF file, without using
# add_offset, scale_factor and _FillValue)
struct Variable{NetCDFType,N,TDS} <: AbstractNCVariable{NetCDFType, N}
    ds::TDS
    varid::Cint
    dimids::NTuple{N,Cint}
end

# must be mutable to register a finalizer
mutable struct NCDataset{TDS,Tmaskingvalue} <: AbstractNCDataset where TDS <: Union{AbstractNCDataset,Nothing}
    # parent_dataset is nothing for the root dataset
    parentdataset::TDS
    ncid::Cint
    iswritable::Bool
    # true of the NetCDF is in define mode (i.e. metadata can be added, but not data)
    # need to be a reference, so that remains syncronised when copied
    isdefmode::Base.RefValue{Bool}
    # mapping between variables related via the bounds attribute
    # It is only used for read-only datasets to improve performance
    _boundsmap::Dict{String,String}
    maskingvalue::Tmaskingvalue
end

const Dataset = NCDataset
