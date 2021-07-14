module DateDataFrames

using Base: padding
export DateDataFrame, resample_nearest, resample, Nearest,
        timestamp, values, names, rename, rename!, diff, lead, moving

using DataFrames
import DataFrames: names, rename, rename!
using Dates
using Statistics

include("date_dataframes.jl")
include("resample.jl")
include("misc.jl")

end
