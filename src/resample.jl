
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
    idx_vec[i:n] .= length(dtv)
    return idx_vec
end

abstract type ResampleMethod end

struct Nearest <: ResampleMethod end


function resample(::Nearest, ddf::DateDataFrame, r::StepRange{DateTime})
    idx_vec = resample_nearest(ddf.timestamp, r)
    return DateDataFrame(r, ddf.df[idx_vec, :])
end

_get_delta(step::Period, probe_coef) = Millisecond(step) * probe_coef
_get_delta(step::Period, probe_coef::Int) = step * probe_coef

"""
probe_coef is used to handle following format to encode [0, 1/24], [1/24, 2/24], ...:

nextfloat(0)
prevfloat(1/24)
nextfloat(1/24)
prevfloat(2/24)
...
"""
function resample(::Nearest, ddf::DateDataFrame, step::Period; probe_coef=0, drop=true)
    delta = _get_delta(step, probe_coef)

    bt = round(ddf.timestamp[1], typeof(step))
    et = round(ddf.timestamp[end], typeof(step))

    if drop
        while bt + delta < ddf.timestamp[1]
            bt += step
        end
        while et + delta > ddf.timestamp[end]
            et -= step
        end
    end

    r = bt:step:et 
    test_r = (bt+delta):step:(et+delta)

    idx_vec = resample_nearest(ddf.timestamp, test_r)
    
    return DateDataFrame(r, ddf.df[idx_vec, :])
end
