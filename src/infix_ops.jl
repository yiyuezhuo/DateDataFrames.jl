
function _iter_xv_yv(xv::Vector{<:DateDataFrame}, yv::Vector{<:DateDataFrame})
    @assert length(xv) == length(yv)
    return zip(xv, yv)
end


# \oplus
function ⊕(xv::Vector{<:DateDataFrame}, yv::Vector{<:DateDataFrame})
    return [x .+ y for (x, y) in _iter_xv_yv(xv, yv)]
end

# \ominus
function ⊖(xv::Vector{<:DateDataFrame}, yv::Vector{<:DateDataFrame})
    return [x .- y for (x, y) in _iter_xv_yv(xv, yv)]
end

# \otimes
function ⊗(xv::Vector{<:DateDataFrame}, yv::Vector{<:DateDataFrame})
    return [x .* y for (x, y) in _iter_xv_yv(xv, yv)]
end

# \oslash, \odiv is ⨸
function ⊘(xv::Vector{<:DateDataFrame}, yv::Vector{<:DateDataFrame})
    return [x ./ y for (x, y) in _iter_xv_yv(xv, yv)]
end

# \otimes
function ⊗(xv::Vector{<:DateDataFrame}, yv::Vector{<:Real})
    return [x .* y for (x, y) in zip(xv, yv)]
end

# \otimes
function ⊗(xv::Vector{<:DateDataFrame}, y::Real)
    return [x .* y for x in xv]
end

# \oslash
function ⊘(xv::Vector{<:DateDataFrame}, yv::Vector{<:Real})
    return [x ./ y for (x, y) in zip(xv, yv)]
end

# \oslash
function ⊘(xv::Vector{<:DateDataFrame}, y::Real)
    return [x ./ y for x in xv]
end
