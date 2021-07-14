
"""
DateDataFrame add timestamp to following objects:

df::DataFrame
df[1, :] # DataFrameRow
df[!, :symbol] # Vector{Float64} # pandas.series like
df[1:2, :] # DataFrame
"""
struct DateDataFrame{TT <: Union{AbstractVector{DateTime}, DateTime}, DT <: Union{AbstractDataFrame, DataFrameRow, AbstractVector}}
    timestamp::TT
    df::DT
end

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

function Base.getindex(ddf::DateDataFrame, row_idx, col_idx)
    t_idx = translate_idx(ddf.timestamp, row_idx)
    # @show t_idx
    df = ddf.df[t_idx, col_idx]
    # timstamp = ddf.timestamp[t_idx]
    timestamp = translate_timestamp(ddf.timestamp, t_idx)
    return DateDataFrame(timestamp, df)
end

function Base.getindex(ddf::DateDataFrame{<:Any, <:AbstractVector}, row_idx)
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
