module DateDataFrames

using Base: padding
export DateDataFrame, resample_nearest, resample, Nearest,
        timestamp, values, names, rename, rename!, lead, moving,
        ⊕, ⊖, ⊗, ⊘

using DataFrames
import DataFrames: names, rename, rename!
using Dates
using Statistics
using RecipesBase

include("date_dataframes.jl")
include("resample.jl")
include("misc.jl")
include("infix_ops.jl")
include("recipes.jl")

end
