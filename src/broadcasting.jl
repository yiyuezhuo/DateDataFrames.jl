
const TupleWithDDF = Union{Tuple{<:DateDataFrame}, Tuple{<:DateDataFrame, <:Any}, Tuple{<:Any, <:DateDataFrame}}

Base.broadcastable(ddf::DateDataFrame) = ddf

Base.ndims(::Type{<:DateDataFrame{<:Any, <:AbstractVector}}) = 1
Base.ndims(::Type{<:DateDataFrame}) = 2

translate_arg(x) = x
translate_arg(x::DateDataFrame) = x.df

function Base.materialize!(ddf::DateDataFrame, bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:TupleWithDDF})
    broadcast!(bc.f, ddf.df, translate_arg.(bc.args)...)
    return ddf
end

function Base.materialize!(ddf::DateDataFrame, bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing})
    broadcast!(bc.f, ddf.df, bc.args...)
    return ddf
end

function Base.materialize(bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:TupleWithDDF})
    ddf = bc.args[1]
    df = broadcast(bc.f, translate_arg.(bc.args)...)
    @assert length(ddf.timestamp) == size(df, 1)
    return DateDataFrame(ddf.timestamp, df)
end

function Base.materialize(bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:TupleWithDDF})
    ddf = bc.args[2]
    df = broadcast(bc.f, translate_arg.(bc.args)...)
    @assert length(ddf.timestamp) == size(df, 1)
    return DateDataFrame(ddf.timestamp, df)
end
