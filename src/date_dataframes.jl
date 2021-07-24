
"""
DateDataFrame add timestamp to following objects:

df::DataFrame
df[1, :] # DataFrameRow
df[!, :symbol] # Vector{Float64} # pandas.series like
df[1:2, :] # DataFrame
"""
const DateTimeOrVec = Union{AbstractVector{DateTime}, DateTime}

struct DateDataFrame{TT <: DateTimeOrVec, DT <: Union{AbstractDataFrame, DataFrameRow, AbstractVector}}
    timestamp::TT
    df::DT
end

const DateDataFrameVecEnd = DateDataFrame{<:DateTimeOrVec, <:AbstractVector}

function show_timestamp(ts::AbstractVector{DateTime})
    return "$time::$(typeof(ts)) span=> $(ts[1])->$(ts[end])"
end

function show_timestamp(ts::DateTime)
    "date_time=> $ts"
end

function Base.show(io::IO, ddf::DateDataFrame)
    print(io, "DateDataFrame: $(show_timestamp(ddf.timestamp)) extended df=")
    sdf = hcat(DataFrame(Dict(:__date => ddf.timestamp)), ddf.df)
    Base.show(io, sdf)
end

type_translate(timestamp, df) = DateDataFrame(timestamp, df)
type_translate(timestamp, df::Number) = df

function Base.getindex(ddf::DateDataFrame, row_idx, col_idx)
    t_idx = translate_idx(ddf.timestamp, row_idx)
    # @show t_idx
    df = ddf.df[t_idx, col_idx]
    # timstamp = ddf.timestamp[t_idx]
    timestamp = translate_timestamp(ddf.timestamp, t_idx)
    return type_translate(timestamp, df)
end

function Base.getindex(ddf::DateDataFrameVecEnd, row_idx)
    t_idx = translate_idx(ddf.timestamp, row_idx)
    return DateDataFrame(ddf.timestamp[t_idx], ddf.df[t_idx])
end

function Base.getindex(ddf::DateDataFrameVecEnd, row_idx::Union{Int, DateTime})
    t_idx = translate_idx(ddf.timestamp, row_idx)
    return ddf.df[t_idx]
end

function Base.setindex!(ddf::DateDataFrame, value, row_idx, col_idx)
    t_idx = translate_idx(ddf.timestamp, row_idx)
    ddf.df[t_idx, col_idx] = value
end

function Base.setindex!(ddf::DateDataFrame{<:Any, <:AbstractVector}, value, idx)
    t_idx = translate_idx(ddf.timestamp, idx)
    ddf.df[t_idx] = value
end

# General fallback
function translate_idx(ts, row_idx)
    return row_idx
end

function translate_idx(ts::AbstractVector{DateTime}, dt::DateTime)
    idx = searchsorted(ts, dt)
    if length(idx) > 0
        return first(idx)
    else length(idx) == 0
        error("$dt not found in index")
    end
end

function translate_idx(ts::StepRange{DateTime, <:Any}, dt::DateTime)
    d = dt - ts.start
    step = typeof(d)(ts.step)
    # @show ts ts.start d ts.step typeof(d)(ts.step) (d % typeof(d)(ts.step))
    if d % step == zero(typeof(d))
        idx = d ÷ step + 1
        return idx
    end
    error("DateTime $dt is not in index")
end

function translate_idx(ts, dt::AbstractVector{DateTime})
    return translate_idx.([ts], dt)
end

# TODO, add a dispatch for row_idx::StepRange{DateTime, <:Any}

function translate_timestamp(ts::AbstractVector{<:DateTime}, idx)
    return ts[idx]
end

function translate_timestamp(ts::AbstractVector{<:DateTime}, ::typeof(!))
    return ts
end

Base.eachcol(ddf::DateDataFrame) = Base.eachcol(ddf.df)
Base.size(ddf::DateDataFrame, args...) = Base.size(ddf.df, args...)

Base.sum(ddf::DateDataFrameVecEnd) = sum(ddf.df)
Base.first(ddf::DateDataFrame, row_idx=1:1) = ddf[row_idx, :]
Base.first(ddf::DateDataFrameVecEnd, row_idx=1:1) = ddf[row_idx]

Base.cumsum(ddf::DateDataFrameVecEnd) = DateDataFrame(ddf.timestamp, cumsum(ddf.df))

# While it's possible to implement `iterate` interface for DateTimeOrVec, I don't do it to capture other errors easily.

#=
Reference:
https://github.com/JuliaData/DataFrames.jl/blob/main/src/abstractdataframe/abstractdataframe.jl#L400
=#
function Base.:(==)(ddf1::DateDataFrame, ddf2::DateDataFrame)
    return ddf1.timestamp == ddf2.timestamp && ddf1.df == ddf2.df
end

Base.:(-)(dff::DateDataFrameVecEnd) = DateDataFrame(ddf.timestamp, -ddf.df)

function Base.hcat(ddf1::DateDataFrame, ddf2::DateDataFrame)
    @assert ddf1.timestamp == ddf2.timestamp
    return DateDataFrame(ddf1.timestamp, hcat(ddf1.df, ddf2.df))
end

function Base.vcat(ddf1::DateDataFrame, ddf2::DateDataFrame)
    @assert ddf1.timestamp[end] <= ddf2.timestamp[begin]
    return DateDataFrame(vcat(ddf1.timestamp, ddf2.timestamp), vcat(ddf1.df, ddf2.df))
end
