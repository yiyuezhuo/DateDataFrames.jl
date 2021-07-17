
#=
function Base.broadcasted(f::typeof(*), ddf::DateDataFrame{<:Any, <:Union{AbstractDataFrame, DataFrameRow}}, x)
    df = Base.broadcasted(f, ddf.df, x) |> Base.materialize
    return DateDataFrame(ddf.timestamp, df)
end

function Base.broadcasted(f::typeof(*), ddf::DateDataFrame{<:TTT, <:AbstractVector}, x)
    return Base.broadcasted(f, ddf.df, x)
end
=#


function Base.broadcasted(::typeof(*), ddf_l::DateDataFrame{<:TTT, <:AbstractVector}, ddf_r::DateDataFrame{<:TTT, <:AbstractVector})
    @assert ddf_l.timestamp == ddf_r.timestamp
    return DateDataFrame(ddf_l.timestamp, ddf_l.df .* ddf_r.df)
end

#=
function Base.broadcasted(f::typeof(*), ddf::DateDataFrame{<:TTT, <:AbstractVector}, x)
    return Base.broadcasted(f, ddf.df, x)
end
=#

function Base.broadcasted(f::Union{typeof.([+, -, *, /, ==])...}, ddf_l::DateDataFrame, x)
    # @assert ddf_l.timestamp == ddf_r.timestamp
    df = broadcast(f, ddf_l.df, x)
    @assert size(df, 1) == length(ddf_l.timestamp)
    return DateDataFrame(ddf_l.timestamp, df)
end

function Base.broadcasted(f::Union{typeof.([+, -, *, /, ==])...}, ddf_l::DateDataFrame, ddf_r::DateDataFrame)
    @assert ddf_l.timestamp == ddf_r.timestamp
    df = broadcast(f, ddf_l.df, ddf_r.df)
    # @assert size(df, 1) == length(ddf.timestamp)
    return DateDataFrame(ddf_l.timestamp, df)
end

function Base.materialize!(ddf::DateDataFrame, x::Base.Broadcast.Broadcasted{<:Any, <:Any, <:Any, <:Tuple})
    return Base.materialize!(ddf.df, x)
end

function Base.materialize!(ddf::DateDataFrame, x::DateDataFrame)
    return Base.materialize!(ddf.df, x.df)
end

function Base.materialize!(x, ddf::DateDataFrame)
    return Base.materialize!(x, ddf.df)
end


#=
function Base.materialize!(ddf::DateDataFrame, x::DateDataFrame)
    Base.materialize!(ddf.df, x.df)
end
=#

Base.dotview(ddf::DateDataFrame, x, y) = Base.dotview(ddf.df, translate_idx(ddf.timestamp, x), y)

#=
function Base.dotview(ddf::DateDataFrame, x::AbstractVector{DateTime}, y)
    return Base.dotview(ddf.df, x, y)
end
=#