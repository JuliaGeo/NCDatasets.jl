---
title: 'NCDatasets.jl: a Julia package for manipulating netCDF data sets'
tags:
  - julia
  - netcdf
  - oceanography
  - meteorology
  - earth-observation
  - climatology
  - opendap
  - climate-and-forecast-conventions
authors:
  - name: Alexander Barth
    orcid: 0000-0003-2952-5997
    affiliation: 1
affiliations:
 - name: GHER, University of Liège, Liège, Belgium
   index: 1
date: 13 January 2024
bibliography: paper.bib
---

# Summary

NCDatasets is a Julia package that allows users to read, create and modify netCDF files (Network Common Data Format). It is based on the Unidata netCDF library [@Rew90; Rew2006; @OGC_netCDF] which also supports reading data from remote servers using OPeNDAP (Open-source Project for a Network Data Access Protocol, https://www.opendap.org) and the Zarr file format [@OGC_Zarr]. These additional formats are also accessible to users of NCDatasets.

The aim of NCDatasets is to expose the data and metadata stored in the NetCDF file as lazy data-structures (in particular arrays and dictionaries) used in Julia.
Lazy in this context means that only the requested subset of data is loaded into RAM or written to the disk. One of the design goals of NCDatasets and the netCDF library in general is being able to work with datasets which are potentially larger than the total amount of RAM in a system and to process that data per subset.

NetCDF allows users to add metadata to datasets and individual variables in form of a list of key value-pairs called attributes. The meaning of these attributes is
standardized in the CF conventions [@Eaton2023]. While originally proposed for NetCDF files, the CF conventions are now also applied in the context of other formats like GRIB (e.g. the Julia package [GRIBDatasets](https://github.com/JuliaGeo/GRIBDatasets.jl) or the python package [cfgrib](https://github.com/ecmwf/cfgrib)).


# Statement of need

NetCDF is a commonly used data format in Earth sciences (in particular oceanography, atmospheric sciences and climatology) to store model data, satellite observations and in situ observations. It is particularly well established as a format for distributing and archiving data. The Julia programming language with its native array types, just-in-time compilation and automatic function specialization based on data types are well suited for processing and analyzing large amounts of data often found in Earth sciences.
Therefore, a convenient API mapping the concepts for the NetCDF format and CF convention to the corresponding equivalents of the Julia programming language is desirable.
There are currently 64 registered Julia packages (as for 15 January 2024) that have NCDatasets as direct or indirect dependency (not counting for optional dependencies).
For example, NCDatasets is used with satellite data [@Barth2022; @Doglioni2023], in situ observations [@Belgacem21; @Shahzadi21] as well as numerical ocean models [@OceananigansJOSS] and atmospheric models [@SpeedyWeather].


# Installation

NCDatasets supports Julia 1.6 and later and can be installed with the Julia package manager using the following Julia commands:

```julia
using Pkg
Pkg.add("NCDatasets")
```

This will automatically install all dependencies and in particular the Unidata netCDF C library for which compiled binaries are currently available for Linux, FreeBSD, Mac OS and Windows thanks to the efforts of the [Yggdrasil.jl](https://github.com/JuliaPackaging/Yggdrasil/) project.

# Features

The main objects in the netCDF data model are the dataset (typically representing a whole file), variables (named n-dimensional arrays with named dimensions), dimensions (mapping the dimension names to the corresponding length), attributes and groups (a dataset contained within a dataset). Groups can be recursively nested. Variable names must be unique within a given group, but in two different groups, variable names can be re-used. Current features of NCDatasets include:

* Attributes, dimensions and groups are exposed to users as dictionary-like objects. Modifying them will directly modify the underlying NetCDF file as long as the file is open in write mode.
* Variables are exposed as array-like objects. Indexing these arrays with the usual Julia syntax will result in loading the corresponding subset into memory. Likewise, assigning a value to a subset will write the data to the disk.
* The netCDF C API provides several functions to query information about the various objects of the netCDF data model.  It is possible to query the data and metadata of a NetCDF file in the same way that one would query an array or dictionary.
* Every time a netCDF variable is loaded the required memory is automatically allocated. Once this memory is no longer used it will be deallocated by Julia's garbage collector. For high-performance applications, the repeated allocation and deallocation can cause a significant performance overhead. For this use-case, NCDatasets provides in-place variants for loading data.
* Data stored in a contiguous ragged array representation [@Hassell2017; @Eaton2023] are loaded as a vector of vectors. It is typically used to load a list of in situ profiles or time series, each of different length.
* Storage parameters like compression and data chunks can be queried and defined.
* Data transformations defined via the CF conventions are applied per default (including scaling, adding an offset, conversion to the `DateTime` structure). Several calendars are standardized in the CF conventions (standard, Gregorian, proleptic Gregorian, Julian, all leap, no leap, 360 day). Where possible, dates are automatically converted to Julia's native date time type, which uses the proleptic Gregorian calendar conforming to the ISO 8601 standard. Date types are handled using the package [CFTimes](https://github.com/JuliaGeo/CFTimes.jl) (originally part of NCDatasets)
* Additional functionality includes multi-file support (virtually concatenating variables of multiple NetCDF variable spanning over multiple files), a view of the variable and datasets (virtual subset without loading the whole data in memory), subset variables and dataset using coordinate values instead of indices using the package [CommonDataModel](https://github.com/JuliaGeo/CommonDataModel.jl) (also originally part of NCDatasets).


# Similar software

The Julia package [NetCDF.jl](https://github.com/JuliaGeo/NetCDF.jl) from Fabian Gans and contributors is an alternative to this package which supports a more Matlab/Octave-like interface for reading and writing netCDF files while this package, NCDatasets, is more influenced by the python [netCDF4](https://github.com/Unidata/netcdf4-python) package. In the R community, the packages [RNetCDF](https://github.com/mjwoods/RNetCDF) and [ncdf4](https://cirrus.ucsd.edu/~pierce/ncdf/) fulfill a similar role.

# Acknowledgements

I thank [all contributors](https://github.com/Alexander-Barth/NCDatasets.jl/graphs/contributors) to this package, among others, George Datseris, Tristan Carion, Martijn Visser, Charles Troupin, Rafael Schouten, Argel Ramírez Reyes, Kenechukwu Uba, Philippe Roy, Gregory L. Wagner, Gael Forget and Haakon Ludvig Langeland Ervik as well as Unidata for the [netCDF C library](https://github.com/Unidata/netcdf-c) and their time and efforts responding to my questions and issues. All contributors to the [Yggdrasil.jl](https://github.com/JuliaPackaging/Yggdrasil/) project for their effort in building the netCDF library and the required dependencies are also acknowledged.

# Funding

Acknowledgment is given to the F.R.S.-FNRS (Fonds de la Recherche Scientifique de Belgique) for funding the position of Alexander Barth. This work was partly performed with funding from the Blue-Cloud 2026 project under the Horizon Europe programme, Grant Agreement No. 101094227.

# References
