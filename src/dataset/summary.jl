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
            with x, a string, the name of the aggregation funcion(e.g. mean, variance, ...),
            and n, an integer, the maximal number of lags to consider
"""
function agg_autocorrelation(x::AbstractArray{T} where T<:Real, p::Dict{String, Any})
    func = p["f_agg"]
    maxlag = p["maxlag"]

    R::AbstractArray = zeros(maxlag)
    μ = mean(x)
    σ²= var(x)

    for i in 1:maxlag
        aux = 0.

        for t in 1:(length(x) - i)
            aux += (x[t] - μ) * (x[t+i] - μ)
        end

        R[i] = ( 1 / ( (length(x) - i) * σ² ) ) * aux
    end

    return getfield(Statistics, Symbol(func))(R)

end

"""
agg_linear_trend
Calculates a linear least-sqaures regression for values of the
time series that we aggregated over chunks versus the sequence
from 0 up to the number of chunks minus one.
Input: x-> time series to calculate the feature of
       p-> dictionaries {"attr":x, "chunk_len":l, "f_agg":f}
            x,f strings;
            l integer
"""

#TODO

"""
Implements a vectorized approximate entropy algorithm.
Input: x-> time series to calculate the feature of
       m-> length of compared run of data (int)
       r-> filtering level, must be positive (float)
"""
function approximate_entropy(x::AbstractArray{T} where T<:Float, m::Int, r::Float)
    dist(x_i, x_j) =

    n = length(x)

    x_re = Array([[ x[j] for j in i:(i+m-1) ] for i in 1:(n-m+1)])

    # GO AHEAD
end

# ar_coefficient TODO

# augmented_dickey_fuller TODO

# Calculates the autocorrelation of the specified lag.
function autocorrelation(x::AbstractArray{T} where T<:Float, lag::Int)
    n = length(x)
    μ = mean(x)
    σ²= var(x)

    sum = 0.
    for t in 1:(n-lag)
        sum += (x[t] - μ) * (x[t+lag] - μ)
    end

    return (1 / ((n-lag) * σ²)) * sum
end

"""
Returns the correlation from first digit distribution when compared
 to the Newcomb-Benford's Law fistribution
"""
function benford_correlation(x::AbstractArray{T} where T<:Real)
    # Take first digit from data
    x = Array([last(digits(trunc(Int, abs(x[i]))) for i in 1:length(x)])

    # Benford distribution
    P = Array([log10(1 + 1/n) for n in 1:9])

    # Data distribution
    D = Array([count(i -> i==n, x)/lenght(x) for n in 1:9])

    # Return the correlation between benford distribution and data distribution
    return cor(P,D)
end
