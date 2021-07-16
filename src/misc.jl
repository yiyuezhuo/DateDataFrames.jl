
timestamp(ddf::DateDataFrame) = ddf.timestamp

Base.values(ddf::DateDataFrame) = error("values is removed for DateDataFrame")

# `colnames` is removed in favor of `DataFrames.names`

names(ddf::DateDataFrame) = names(ddf.df)

function Base.diff(ddf::DateDataFrame; padding=false)
    names_df = names(ddf.df)
    df = ddf.df[2:end, :] .- ddf.df[1:end-1, :]
    if padding
        nan_pad = DataFrame(fill(NaN, 1, length(names_df)), names_df)
        df = vcat(nan_pad, df)
        ts = ddf.timestamp
    else
        ts = ddf.timestamp[2:end]
    end
    return DateDataFrame(ts, df)
end

function lead(ddf::DateDataFrame)
    return DateDataFrame(ddf.timestamp[1:end-1], ddf.df[2:end, :])
end

rename(ddf::DateDataFrame) = rename(ddf.df)
rename!(ddf::DateDataFrame) = rename!(ddf.df)

function rolling_mean(arr::AbstractVector, n::Int; padding=false)
    ret_length = length(arr) - n + 1

    ret = Vector{eltype(arr)}(undef, ret_length)
    ret[1] = sum(arr[1:n])
    for i in 2:ret_length
        ret[i] = ret[i-1] + arr[n + i - 1] - arr[i - 1]
    end
    ret = ret ./ n
    if padding
        ret = vcat(fill(NaN, n-1), ret)
    end
    return ret
end

function moving(::typeof(mean), ddf::DateDataFrame, n::Int; padding=false)
    pair_vec = [key=>rolling_mean(ddf.df[!, key], n; padding=padding) for key in names(ddf.df)]
    df = DataFrame(pair_vec)
    ts = padding ? ddf.timestamp : ddf.timestamp[n:end]
    return DateDataFrame(ts, df)
end
