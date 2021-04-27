using Statistics

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

"""
Descriptive statistics on the autocorrelation of the time series x.
Calculates the value of an aggregation function fₐ over
    the autocorrelation for different lags.
Input:  x -> time series to calculate the feature of
        param -> dictionaries {"f_agg":x, "maxlag":n},
            with x, a string, the name of a funcion(e.g. mean, variance),
            and n, an integer, the maximal number of lags to consider
"""
function agg_autocorrelation(x::AbstractArray{T} where T<:Real, p::Dict{String, Any})
    func = p["f_agg"]
    maxlag = p["maxlag"]

    R::AbstractArray = zeros(maxlag)

    for i in 1:maxlag
        aux = 0.
        μ = mean(x)
        σ²= var(x)

        for t in 1:(length(x) - i)
            aux += (x[t] - μ) * (x[t+i] - μ)
        end

        R[i] = ( 1 / ( (length(x) - i) * σ² ) ) * aux
    end

    return getfield(Statistics, Symbol(func))(R)

end
