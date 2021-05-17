using Statistics
using StatsBase

# Absolute energy of the time series, the sum over the squared values
abs_energy(x::AbstractArray{T} where T<:Real) = mapreduce(x -> x * x, +, x) #using reduce(map()) is faster but with more mem allocation

# Highest absolute value of the time series x
absolute_maximum(x::AbstractArray{T} where T<:Real) = maximum(abs, x)

# Sum over the abs value of consecutive changes in the series x
function absolute_sum_of_changes(x::AbstractArray{T} where T<:Real)
    diff = Real[]

    for i in 1:length(x)-1
        push!(diff,x[i+1] - x[i])
    end

    return sum(map(abs,diff))
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
function agg_autocorrelation(x::AbstractArray{T} where T<:Real, func::String, maxlag::Int)

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

    # Where the percentage is 0, set to 1 to avoid Nan values?
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
function change_quantiles(x::AbstractArray{T} where T<:Real, ql::Float64, qh::Float64, f_agg::String)
        # Compute the quantiles
        q = quantile(vec(x), [ql, qh], sorted=true)

        # Corridor between the 2 quantiles
        corr = Real[]
        for i in 1:length(x)
            if x[i] >= q[1] && x[i] <= q[2]
                push!(corr, x[i])
            end
        end

        # Return the aggregation function of corridor
        return getfield(Statistics, Symbol(f_agg))(corr)
end

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

"""
Return the first location of the maximum value of x.
The position is calculated relatively to the length of x
"""
first_location_of_maximum(x::AbstractArray{T} where T<:Real) = findmax(x)[2] / length(x)

"""
Return the first location of the minimum value of x.
The position is calculated relatively to the length of x
"""
first_location_of_minimum(x::AbstractArray{T} where T<:Real) = findmin(x)[2] / length(x)

# Checks if any value in x occurs more than once
has_duplicate(x::AbstractArray{T} where T<:Real) = return length(x) != length(unique(x))

# Checks if the maximum value of x is observed more than once
has_duplicate_max(x::AbstractArray{T} where T<:Real) = if count(i -> i == maximum(x), x) > 1 return true else return false end

# Checks if the minimum value of x is observed more than once
has_duplicate_min(x::AbstractArray{T} where T<:Real) = if count(i -> i == minimum(x), x) > 1 return true else return false end

"""
Does time series have large standard deviation?
Return boolean denoting if the standard deviation of x
is higher than 'r' times the range.
"""
large_standard_deviation(x::AbstractArray{T} where T<:Real, r::Float64) = return std(x) > r * (maximum(x) - minimum(x))

# Returns the relative last location of tha maximum value of x
last_location_of_maximum(x::AbstractArray{T} where T<:Real) = findmax(reverse(x))[2] / length(x)

# Returns the relative last location of tha minimum value of x
last_location_of_minimum(x::AbstractArray{T} where T<:Real) = findmin(reverse(x))[2] / length(x)

# Returns the length of the longest consecutive subsequence in x that is bigger than the mean of x
function longest_strike_above_mean(x::AbstractArray{T} where T<:Real)
    aux = x.>mean(x)
    max_strike = 0
    i=1

    while i <= length(aux)
        if aux[i] == 1
            c = 1
            i+=1
            while i <= length(aux)
                if aux[i] == 1
                    c+=1
                else
                    break
                end
                i+=1
            end
            if c > max_strike
                max_strike = c
            end
        else
            i+=1
        end
    end

    return max_strike
end

# Returns the length of the longest consecutive subsequence in x that is lower than the mean of x
function longest_strike_below_mean(x::AbstractArray{T} where T<:Real)
    aux = x.<mean(x)
    max_strike = 0
    i=1

    while i <= length(aux)
        if aux[i] == 1
            c = 1
            i+=1
            while i <= length(aux)
                if aux[i] == 1
                    c+=1
                else
                    break
                end
                i+=1
            end
            if c > max_strike
                max_strike = c
            end
        else
            i+=1
        end
    end

    return max_strike
end

# Average over first differences
function mean_abs_change(x::AbstractArray{T} where T<:Real)
    diff = Real[]

    for i in 1:length(x)-1
        push!(diff,x[i+1] - x[i])
    end

    return mean(map(abs, diff))
end

# Average over time sereis differences
mean_change(x::AbstractArray{T} where T<:Real) = (x[end] - x[1]) / (length(x) - 1)

# Calculates the arithmetic mean of the n absolute maximum values of the time series
function mean_n_absolute_max(x::AbstractArray{T} where T<:Real, n::Int)
    aux = sort(map(abs, x))
    return mean(aux[length(aux) - (n - 1) : end])
end

# Returns the mean value of a central approximation of the secondo derivative
mean_second_derivative_central(x::AbstractArray{T} where T<:Real) = (x[end] - x[end - 1] - x[2] - x[1]) / (2 * (length(x) - 2))

# Calculates the number of crossing of x on m.
function number_crossing_m(x::AbstractArray{T} where T<:Real, m::Float64)
    positive = x .> m
    diff = Int[]

    for i in 1:length(x) - 1
        push!(diff, positive[i+1] - positive[i])
    end

    return count(i -> i != 0, diff)
end

# Returns the percentage of non-unique data points.
function percentage_of_reoccurring_datapoints_to_all_datapoints(x::AbstractArray{T} where T<:Real)
    value_counts = countmap(x)
    reoccurring_values = 0

    for item in value_counts
        if item[2] > 1
            reoccurring_values += 1
        end
    end

    return reoccurring_values / length(x)
end

# Returns the percentage of values that are present in the time series more than once
function percentage_of_reoccurring_values_to_all_values(x::AbstractArray{T} where T<:Real)
    value_counts = countmap(x)
    reoccurring_values = 0
    unique_values = 0

    for item in value_counts
        if item[2] > 1
            reoccurring_values += 1
        else
            unique_values += 1
        end
    end

    return reoccurring_values / unique_values
end

# Count observed values within the interval [min, max)
range_count(x::AbstractArray{T} where T<:Real, min::Float64, max::Float64) = count(i -> i>=min && i<max, x)

# Ratio of values that are mroe than r * std(x) away from the mean of x
function ratio_beyond_r_sigma(x::AbstractArray{T} where T<:Real, r::Float64)
    μ = mean(x)
    r_sigma = r * std(x)

    aux = map(abs, map(x -> x - μ, x))

    aux = Array([aux[i] > r_sigma ? aux[i] : 0 for i in 1:length(aux)])

    return sum(aux) / length(x)
end

"""
Returns a factow which is 1 if all values in the time series occur only once,
and below one if this is not the case
"""
function ratio_value_number_to_time_series_length(x::AbstractArray{T} where T<:Real)
    value_counts = countmap(x)
    unique = Real[]

    for item in value_counts
        if item[2] == 1
            push!(unique, item[2])
        end
    end

    return length(unique) / length(x)
end

# Returns the root mean square of the time series
root_mean_square(x::AbstractArray{T} where T<:Real) = sqrt(mean(map(x -> x^2, x)))

# Calculate and return sample entropy of x
function sample_entropy(x::AbstractArray{T} where T<:Real)
    m = 2
    tolerance = 0.2 * std(x)

    xmi = Array([x[i : i+m-1] for i in 1:length(x)-m])
    xmj = Array([x[i : i+m-1] for i in 1:length(x)-m+1])

    xmi = maximum(collect(hcat(xmi...)'), dims=2)
    xmj = maximum(collect(hcat(xmj...)'), dims=2)

    B = sum( Array([sum(x -> x <= tolerance, map(abs, xmi_i .- xmj)) - 1 for xmi_i in xmi]))

    m += 1
    xm = Array([x[i:i+m-1] for i in 1:length(x)-m+1])
    xm = maximum(collect(hcat(xm...)'), dims=2)

    A = sum( Array([sum(x -> x <= tolerance, map(abs, xm_i .- xm)) - 1 for xm_i in xm]))

    return -log(A/B)
end

# Returns the sum of all data points, that are present in the time series more than once
function sum_of_reoccurring_data_points(x::AbstractArray{T} where T<:Real)
    value_counts = countmap(x)
    reoc = Real[]

    for item in value_counts
        if item[2] > 1
            for i in 1:item[2]
                push!(reoc, item[1])
            end
        end
    end

    return sum(reoc)
end

# Returns the sum fo all values, that are present in the time series more than once
