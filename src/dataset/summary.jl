using Statistics
using StatsBase

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

"""
function approximate_entropy(x::AbstractArray{T} where T<:Real, m::Int, r::Real)
    dist(x_i, x_j) =

    n = length(x)

    x_re = Array([[ x[j] for j in i:(i+m-1) ] for i in 1:(n-m+1)])

    # GO AHEAD
end
"""
# ar_coefficient TODO

# augmented_dickey_fuller TODO

# Calculates the autocorrelation of the specified lag.
function autocorrelation(x::AbstractArray{T} where T<:Real, lag::Int)
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
    x = Array([last(digits(trunc(Int, abs(x[i])))) for i in 1:length(x)])

    # Benford distribution
    P = Array([log10(1 + 1/n) for n in 1:9])

    # Data distribution
    D = Array([count(i -> i==n, x)/length(x) for n in 1:9])

    # Return the correlation between benford distribution and data distribution
    return cor(P,D)
end

"""
First bins the values of x into max_bins equidistant bins.
Then calculates the value of binned entropy
"""
function binned_entropy(x::AbstractArray{T} where T<:Real, max_bins::Int)
    # Create equidistant max_bins
    edges = LinRange(minimum(x), maximum(x), max_bins)
    # Fit function requires column vector
    edges = collect(permutedims(edges))

    # Create histogram with the calculated bins
    h = fit(Histogram, vec(x), vec(edges))
    hist = h.weights

    # Vector pₖ with percentages of samples in bin k
    p = hist / length(x)

    # Where probability is 0, set to 1 to avoid Nan values
    p[p.==0] .= 1

    # Return Entropy = - ∑ᵐᵢ₌₁ pᵢ * log(pᵢ)
    return - reduce(+, map(x->x*log(x), p))
end

# Uses c3 statistics to measure non linearity in the time series
function c3(x::AbstractArray{T} where T<:Real, lag::Int)
    n = length(x)
    if 2*lag ≥ n
        return 0
    end

    sum=0.
    for i in 1:(n - 2*lag)
        sum += x[i + 2*lag] * x[i + lag] * x[i]
    end

    return (1 / (n - 2*lag)) * sum
end

"""
First takes a corridor given by the quatiles ql and qh of
the distribution of x. Then calculates the average, absolute
value of consecutive changes of the series x inside this corridor.
"""

#TODO

#This function calculator is an estimate for a time series complexity

function cid_ce(x::AbstractArray{T} where T<:Real, normalize::Bool)
    n = length(x)

    if normalize
        s = std(x)
        if s != 0
            x = (x .- mean(x)) / s
        else
            return 0
        end
    end

    sum = 0.
    for i in 2:n
        sum += (x[i] - x[i-1])^2
    end

    return sqrt(sum)
end

# Returns the percentage of values in x that are higher than t
count_above(x::AbstractArray{T} where T<:Real, t::Float64) = count(i -> i > t, x) / length(x)

# Returns the number of values in x that are higher than the mean of x
count_above_mean(x::AbstractArray{T} where T<:Real) = count(i -> i > mean(x), x)

# Returns the percentage of values in x that are lower than t
count_below(x::AbstractArray{T} where T<:Real, t::Float64) = count(i -> i < t, x) / length(x)

# Returns the number of values in x that are lower than the mean of x
count_below_mean(x::AbstractArray{T} where T<:Real) = count(i -> i < mean(x), x)

# cwt_coefficients
#TODO
