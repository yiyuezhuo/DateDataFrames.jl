
@recipe function f(ddf::DateDataFrame)
    # label --> names(ddf)
    return ddf.timestamp, collect(eachcol(ddf.df))
end

@recipe function f(ddf_vec::Vector{<:DateDataFrame})
    ts_vec = timestamp.(ddf_vec)
    @assert all([ts_vec[1]] .== ts_vec[2:end])
    ts = ddf_vec[1].timestamp
    return ts, [ddf.df for ddf in ddf_vec]
end
