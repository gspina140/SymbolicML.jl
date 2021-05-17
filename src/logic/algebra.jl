##
# Abstract Algebra.
abstract type AbstractAlgebra end

# abstract type HeytingAlgebra end

# TODO remove domain from Boolean Algebra?
# TODO remove parametric types?
# TODO add AbstractHeytingAlgebra whose subtypes are ChainHeytingAlgebra and CustomHeytingAlgebra
struct BooleanAlgebra{DT,MT<:Function,JT<:Function,IT<:Function,BT,TT} <: AbstractAlgebra
    name::String
    domain::DT
    meet::MT
    join::JT
    impl::IT
    bottom::BT
    top::TT
end

struct HeytingAlgebra{DT,MT<:Function,JT<:Function,IT<:Function,BT,TT} <: AbstractAlgebra
    name::String
    domain::DT
    meet::MT
    join::JT
    impl::IT
    bottom::BT
    top::TT
end

# Boolean and
∧(a::Bool,b::Bool)          = ifelse(a == true && a == b, true, false)
∧(a::Int64,b::Int64)        = ifelse(a == 1 && a == b, 1, 0)
∧(a::Float64,b::Float64)    = ifelse(a == 1.0 && a == b, 1.0, 0.0)
∧(a,b,args...)              = ∧(∧(a,b),args...)

# Boolean or
∨(a::Bool,b::Bool)          = ifelse(a == false && a == b, false, true)
∨(a::Int64,b::Int64)        = ifelse(a == 0 && a == b, 0, 1)
∨(a::Float64,b::Float64)    = ifelse(a == 0.0 && a == b, 0.0, 1.0)
∨(a,b,args...)              = ∨(∨(a,b),args...)

# Boolean implication
→(a::Bool,b::Bool)          = ifelse(a == true && b == false, false, true)
→(a::Int64,b::Int64)        = ifelse(a == 1 && b == 0, 0, 1)
→(a::Float64,b::Float64)    = ifelse(a == 1.0 && b == 0.0, 0.0, 1.0)
→(a,b,args...)              = →(→(a,b),args...)

# Heyting chain implication
(↪)(a::Float64, b::Float64) = a ≤ b ? float(1) : b

const BAlgebra = BooleanAlgebra("Boolean Algebra",[0,1],∧,∨,→,0,1)
const HCAlgebra(step::Float64) = HeytingAlgebra("Heyting Chain Algebra", [x for x ∈ 0.0:step:1.0],min,max,↪,0.0,1.0)

function ==̃ₕ(x::Int64, y::Int64; h::Int64=4)
    # |x-y| ≥ h
    if abs(x-y) ≥ h
        return float(0)
    # |x-y| < h
    else
        return (h - abs(x-y))/h
    end
end

function <̃ₕ(x::Int64, y::Int64; h::Int64=4)
    # y-x > h
    if y-x > h
        return float(1)
    # y ≦ x
    elseif y ≤ x
        return float(0)
    # y-x ≦ h
    elseif y-x ≤ h
        return (y-x)/h
    end
end
