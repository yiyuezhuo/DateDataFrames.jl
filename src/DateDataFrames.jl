module DateDataFrames

export DateDataFrame, resample_nearest, resample, Nearest

using DataFrames
using Dates

include("date_dataframes.jl")
include("resample.jl")

end
