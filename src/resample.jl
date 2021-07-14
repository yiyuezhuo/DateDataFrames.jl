
"""
This function should works for Vector{Float}, Vector{DateTime}, etc...
"""
function resample_nearest(dtv::AbstractVector, r::StepRange)
    n = length(r)
    idx_vec = Vector{Int}(undef, n)
    i = 1
    
    while r[i] <= dtv[1]
        if i > n
            return idx_vec
        end
        idx_vec[i] = 1
        i += 1
    end
    for idx in 2:length(dtv)
        while true
            if i > n
                return idx_vec
            end
            if r[i] > dtv[idx]
                break
            end  
            idx_vec[i] = r[i] - dtv[idx-1] <= dtv[idx] - r[i] ? idx - 1 : idx
            i += 1
        end
    end
    idx_vec[i:n] .= idx_vec[end]
    return idx_vec
end

abstract type ResampleMethod end

struct Nearest <: ResampleMethod end


function resample(::Nearest, ddf::DateDataFrame, r::StepRange{DateTime})
    idx_vec = resample_nearest(ddf.timestamp, r)
    return DateDataFrame(r, ddf.df[idx_vec, :])
end

function resample(method::ResampleMethod, ddf::DateDataFrame, step::Period, delta=zero(typeof(step)))
    bt = round(ddf.timestamp[1], typeof(step)) + delta
    et = round(ddf.timestamp[end], typeof(step)) + delta
    r = bt:step:et
    return resample(method, ddf, r)
end
