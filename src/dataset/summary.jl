# Absolute energy of the time series, the sum over the squared values
abs_energy(x::AbstractArray{T} where T<:Real) = mapreduce(x -> x * x, +, x) #using reduce(map()) is faster but with more mem allocation

# Highest absolute value of the time series x
absolute_maximum(x::AbstractArray{T} where T<:Real) = maximum(abs, x)

# Sum over the abs value of consecutive changes in the series x
function absolute_sum_of_changes(x::AbstractArray{T} where T<:Real)
    res = 0.
    for i in 1:length(x)-1
        res += abs(x[i+1] - x[i])
    end
    return res
end
