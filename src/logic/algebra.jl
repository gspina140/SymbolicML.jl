##
# Abstract Algebra.
abstract type AbstractAlgebra end

abstract type HeytingAlgebra end

struct BooleanAlgebra{DT,MT<:Function,JT<:Function,IT<:Function,BT,TT} <: AbstractAlgebra
    name::String
    domain::DT
    meet::MT
    join::JT
    impl::IT
    bottom::BT
    top::TT
end

# Boolean and
∧(a::Bool,b::Bool) = ifelse(a == true && a == b, true, false)
∧(a::Int64,b::Int64) = ifelse(a == 1 && a == b, 1, 0)
∧(a,b,args...) = ∧(∧(a,b),args...)

# Boolean or
∨(a::Bool,b::Bool) = ifelse(a == false && a == b, false, true)
∨(a::Int64,b::Int64) = ifelse(a == 0 && a == b, 0, 1)
∨(a,b,args...) = ∨(∨(a,b),args...)

# Boolean implication
→(a::Bool,b::Bool) = ifelse(a == true && b == false, false, true)
→(a::Int64,b::Int64) = ifelse(a == 1 && b == 0, 0, 1)
→(a,b,args...) = →(→(a,b),args...)

const BAlgebra = BooleanAlgebra("Boolean Algebra",[0,1],∧,∨,→,0,1)
