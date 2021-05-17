@inline function discrete_derivatives(x::AbstractArray{T} where T<:Real;
        d::Int=1)
    @assert d ≥ 0 "discrete derivatives parameter must be greater than 0 (now it is $d)"

    res = zeros(eltype(x), length(x), d+1)

    @inbounds @simd for i in 1:length(x)
        res[i,1] = x[i]
    end

    @inbounds @simd for j in 2:(d+1)
        @inbounds @simd for i in 1:(length(x)-j+1)
            res[i,j] = res[i+1,j-1] - res[i,j-1]
        end
    end

    return res
end

@inline function discrete_derivative(x::AbstractArray{T} where T<:Real; d::Int=1)
    derivatives = discrete_derivatives(x, d=d)
    return derivatives[1:length(x)-d,d+1]
end
