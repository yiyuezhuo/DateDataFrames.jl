
const TupleWithDDF = Union{Tuple{<:DateDataFrame}, Tuple{<:DateDataFrame, <:Any}, Tuple{<:Any, <:DateDataFrame}}

Base.broadcastable(ddf::DateDataFrame) = ddf

Base.ndims(::Type{<:DateDataFrame{<:Any, <:AbstractVector}}) = 1
Base.ndims(::Type{<:DateDataFrame}) = 2

translate_arg(x) = x
translate_arg(x::DateDataFrame) = x.df
translate_arg(x::Base.Broadcast.Broadcasted) = translate_arg(Base.materialize(x)) # TODO: implement "true" fusing
# TODO: This implementation will not work for `ddf .* ddf .+ ddf .* ddf`, however I don't have time to fix it at this time.

function Base.materialize!(ddf::DateDataFrame, bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:TupleWithDDF})
    broadcast!(bc.f, ddf.df, translate_arg.(bc.args)...)
    return ddf
end

function Base.materialize!(ddf::DateDataFrame, bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing})
    broadcast!(bc.f, ddf.df, bc.args...)
    return ddf
end

# TODO: Very ugly hack...

function Base.materialize(bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:Tuple{<:DateDataFrame, <:Any}})
    ddf = bc.args[1]
    df = broadcast(bc.f, translate_arg.(bc.args)...)
    @assert length(ddf.timestamp) == size(df, 1)
    return DateDataFrame(ddf.timestamp, df)
end

function Base.materialize(bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:Tuple{<:Any, <:DateDataFrame}})
    ddf = bc.args[2]
    df = broadcast(bc.f, translate_arg.(bc.args)...)
    @assert length(ddf.timestamp) == size(df, 1)
    return DateDataFrame(ddf.timestamp, df)
end

function Base.materialize(bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle, <:Nothing, <:Any, <:Tuple{<:DateDataFrame, <:DateDataFrame}})
    ddf = bc.args[1]
    df = broadcast(bc.f, translate_arg.(bc.args)...)
    @assert length(ddf.timestamp) == size(df, 1)
    return DateDataFrame(ddf.timestamp, df)
end

function Base.dotview(ddf::DateDataFrame, row_idx)
    t_idx = translate_idx(ddf.timestamp, row_idx)
    return DateDataFrame((@view ddf.timestamp[t_idx]), (@view ddf.df[t_idx]))
end
