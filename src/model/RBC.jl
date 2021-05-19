# import Base: copyto!, isequal, iterate, getindex, length, ndims, size
#
# ##
# # TODO put it as a parameter?
# # constants
# learning_relations = [
#     IdentityIntervalRelation(BAlgebra)
#     ExistentialIntervalRelation{:G}(BAlgebra)
#     ExistentialIntervalRelation{:L}(BAlgebra)
#     ExistentialIntervalRelation{:A}(BAlgebra)
#     ExistentialIntervalRelation{:O}(BAlgebra)
#     ExistentialIntervalRelation{:E}(BAlgebra)
#     ExistentialIntervalRelation{:D}(BAlgebra)
#     ExistentialIntervalRelation{:E}(BAlgebra)
#     ExistentialIntervalRelation{:InvL}(BAlgebra)
#     ExistentialIntervalRelation{:InvA}(BAlgebra)
#     ExistentialIntervalRelation{:InvO}(BAlgebra)
#     ExistentialIntervalRelation{:InvE}(BAlgebra)
#     ExistentialIntervalRelation{:InvD}(BAlgebra)
#     ExistentialIntervalRelation{:InvE}(BAlgebra)
#     UniversalIntervalRelation{:G}(BAlgebra)
#     UniversalIntervalRelation{:L}(BAlgebra)
#     UniversalIntervalRelation{:A}(BAlgebra)
#     UniversalIntervalRelation{:O}(BAlgebra)
#     UniversalIntervalRelation{:E}(BAlgebra)
#     UniversalIntervalRelation{:D}(BAlgebra)
#     UniversalIntervalRelation{:E}(BAlgebra)
#     UniversalIntervalRelation{:InvL}(BAlgebra)
#     UniversalIntervalRelation{:InvA}(BAlgebra)
#     UniversalIntervalRelation{:InvO}(BAlgebra)
#     UniversalIntervalRelation{:InvE}(BAlgebra)
#     UniversalIntervalRelation{:InvD}(BAlgebra)
#     UniversalIntervalRelation{:InvE}(BAlgebra)
# ]
#
# order_relations = [≤, <, >, ≥]
#
# ##
# # TODO we need to see if there is a need for two algebras, i.e., perhaps AbstractHeytingValue -> AbstractAlgebraValue
# abstract type AbstractHeytingValue end
#
# struct HeytingValue{T<:Real} <: AbstractHeytingValue
#     value::T
# end
#
# function Base.show(io::IO, v::HeytingValue)
#     if v.value == 0.0
#         print(io, "⊥")
#     elseif v.value == 1.0
#         print(io, "⊤")
#     else
#         print(io, v.value)
#     end
# end
#
# ##
# # TODO <: HeytingAlgebra?
# mutable struct Node{T}
#     data::T
#     parent::Union{Node{<:AbstractProposition}, Node{<:AbstractRelation}, Node{HeytingValue}}
#     left::Union{Node{<:AbstractProposition}, Node{<:AbstractRelation}, Node{HeytingValue}}
#     right::Union{Node{<:AbstractProposition}, Node{<:AbstractRelation}, Node{HeytingValue}}
#     # Root constructor.
#     Node{T}(data) where T = new{T}(data)
#     Node(data) = new{typeof(data)}(data)
# end
#
# parentnode(currnode::Node) = getproperty(currnode.parent)
# leftnode(currnode::Node) = getproperty(currnode.left)
# rightnode(currnode::Node) = getproperty(currnode.right)
# parentnode!(currnode::Node, pnode::Node) = setproperty!(currnode.parent, pnode)
# leftnode!(currnode::Node, lnode::Node) = setproperty!(currnode.left, lnode)
# rightnode!(currnode::Node, rnode::Node) = setproperty!(currnode.right, rnode)
#
# ##
# abstract type AbstractRule end
#
# mutable struct ClassificationRule <: AbstractRule
#     antecedent::Node
#     consequent::String
# end
#
# antecedent(r::ClassificationRule) = r.antecedent
# consequent(r::ClassificationRule) = r.consequent
#
# function size(rule::ClassificationRule)
#     return _size(antecedent(rule))
# end
#
# function _size(node::Node)
#     s = 1
#     sl = isdefined(node, :left) ? _size(node.left) : 0
#     sr = isdefined(node, :right) ? _size(node.right) : 0
#     return s + sl + sr
# end
#
# function upwards_modaldepth(node::Node)
#     md = isdefined(node, :parent) ? upwards_modaldepth(node.parent) : 0
#     md += typeof(node.data) <:AbstractModalRelation ? 1 : 0
#     return md
# end
#
# function is_leaf(node::Node)
#     return !isdefined(node, :left) && !isdefined(node, :right) ? true : false
# end
#
# function is_internal_node(node::Node)
#     return !is_leaf(node) ? true : false
# end
#
# Base.show(io::IO, n::Node) = print(io, _repr_antecedent(n))
#
# function _repr_antecedent(n::Node)
#     if typeof(n.data) <: AbstractUniversalIntervalRelation
#         return repr(n.data) * "(" * _repr_antecedent(n.left) * " → " * _repr_antecedent(n.right) * ")"
#     elseif typeof(n.data) <: AbstractExistentialIntervalRelation
#         return repr(n.data) * "(" * _repr_antecedent(n.left) * " ∧ " * _repr_antecedent(n.right) * ")"
#     else # Propositions and Heyting values.
#         return repr(n.data)
#     end
# end
#
# function _repr_consequent(c::String)
#     return c
# end
#
# function _repr_classificationrule(r::ClassificationRule)
#     return _repr_antecedent(antecedent(r)) * " ⟹  " * _repr_consequent(consequent(r))
# end
#
# Base.show(io::IO, r::ClassificationRule) = print(io, _repr_classificationrule(r))
#
# ##
# mutable struct ClassificationRules
#     rules::Vector{ClassificationRule}
#     modalities::Vector{<:AbstractModalRelation}
#     minmd::Int64
#     maxnumrules::Int64
#
#     ClassificationRules(rules;
#         modalities::Vector{<:AbstractModalRelation}=learning_relations,
#         minmd::Int64=3,
#         maxnumrules::Int64=10) = new(rules, modalities, minmd, maxnumrules)
# end
#
# rules(Γ::ClassificationRules) = Γ.rules
# modalities(Γ::ClassificationRules) = Γ.modalities
# minmd(Γ::ClassificationRules) = Γ.minmd
# # maxmd(Γ::ClassificationRules) = Γ.maxmd
# maxnumrules(Γ::ClassificationRules) = Γ.maxnumrules
# classes(Γ::ClassificationRules) = collect(Set([consequent(ρ) for ρ ∈ Γ]))
# mean_size(Γ::ClassificationRules) = reduce(+,[size(ρ) for ρ ∈ rules(Γ)])/length(Γ)
# getindex(Γ::ClassificationRules, inds...) = getindex(rules(Γ), inds...)
#
#
# function _repr_rules(Γ::ClassificationRules)
#     res = ""
#     for ρ ∈ rules(Γ)
#         res *= _repr_classificationrule(ρ) * "\n"
#     end
#     return res[1:end-1] # remove the last "\n"
# end
#
# Base.show(io::IO, Γ::ClassificationRules) = print(io, _repr_rules(Γ))
# # p = LowLevelProposition(1, ≤, 0.7, 5)
#
# ##
# # Defined, otherwise it gives errors
# length(crules::ClassificationRules) = length(rules(crules))
# iterate(crules::ClassificationRules) = iterate(rules(crules))
# iterate(crules::ClassificationRules, i::Int64) = iterate(rules(crules), i)
# ndims(::Type{ClassificationRules}) = 1
# size(crules::ClassificationRules) = (length(crules),)
# copyto!(crules::ClassificationRules, b::Base.Broadcast.Broadcasted) = copyto!(rules(crules), b)
#
# ##
# function _rand_levelproposition(numattributes::Int64, relations::Array{Function, 1}, domains::Array{Array{Float64, N} where N, 1})
#     i = rand(1:numattributes)
#     fun = [min, max][rand(1:2)]
#     return Proposition(fun, i, relations[rand(1:length(relations))], domains[i][rand(1:length(domains[i]))])
# end
# FINO A QUA

##
# Abstract relation.
abstract type AbstractRelation end

##
# Abstract proposotional relation.
abstract type AbstractPropositionalRelation     <: AbstractRelation end
# Abstract modal relation.
abstract type AbstractModalRelation             <: AbstractRelation end

##
# Abstract temporal relation.
abstract type AbstractTemporalRelation          <: AbstractModalRelation end
# Abstract spatial relation.
abstract type AbstractSpatialRelation           <: AbstractModalRelation end
# Abstract spatio-temporal relation.
abstract type AbstractSpatioTemporalRelation    <: AbstractModalRelation end

##
# Abstract point (temporal) relation.
abstract type AbstractPointRelation             <: AbstractTemporalRelation end
# Abstract interval (temporal) relation.
abstract type AbstractIntervalRelation          <: AbstractTemporalRelation end
# Abstract rectangle (spatial) relation.
abstract type AbstractRectangleRelation         <: AbstractSpatialRelation end
# Abstract cube (spatio-temporal) relation.
abstract type AbstractCubeRelation              <: AbstractSpatioTemporalRelation end

##
# Abstract existential interval (temporal) relation.
abstract type AbstractExistentialIntervalRelation   <: AbstractIntervalRelation end
# Abstract universal interval (temporal) relation.
abstract type AbstractUniversalIntervalRelation     <: AbstractIntervalRelation end

##
#
struct IdentityIntervalRelation         <: AbstractIntervalRelation end
# Using the singleton design pattern; similar to Val{T}.
struct ExistentialIntervalRelation{T}   <: AbstractExistentialIntervalRelation end
struct UniversalIntervalRelation{T}     <: AbstractUniversalIntervalRelation end
ExistentialIntervalRelation(s::AbstractString)  = ExistentialIntervalRelation{Symbol(s)}()
ExistentialIntervalRelation(s::Symbol)          = ExistentialIntervalRelation{s}()
UniversalIntervalRelation(s::AbstractString)    = UniversalIntervalRelation{Symbol(s)}()
UniversalIntervalRelation(s::Symbol)            = UniversalIntervalRelation{s}()

##
Base.show(io::IO, ::IdentityIntervalRelation)           = print(io, "|=|")

Base.show(io::IO, ::ExistentialIntervalRelation{:G})    = print(io, "⟨G⟩")

Base.show(io::IO, ::ExistentialIntervalRelation{:L})    = print(io, "⟨L⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:A})    = print(io, "⟨A⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:O})    = print(io, "⟨O⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:E})    = print(io, "⟨E⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:D})    = print(io, "⟨D⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:B})    = print(io, "⟨B⟩")

Base.show(io::IO, ::ExistentialIntervalRelation{:InvL}) = print(io, "⟨InvL⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:InvA}) = print(io, "⟨InvA⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:InvO}) = print(io, "⟨InvO⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:InvE}) = print(io, "⟨InvE⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:InvD}) = print(io, "⟨InvD⟩")
Base.show(io::IO, ::ExistentialIntervalRelation{:InvB}) = print(io, "⟨InvB⟩")

Base.show(io::IO, ::UniversalIntervalRelation{:G})      = print(io, "[G]")

Base.show(io::IO, ::UniversalIntervalRelation{:L})      = print(io, "[L]")
Base.show(io::IO, ::UniversalIntervalRelation{:A})      = print(io, "[A]")
Base.show(io::IO, ::UniversalIntervalRelation{:O})      = print(io, "[O]")
Base.show(io::IO, ::UniversalIntervalRelation{:E})      = print(io, "[E]")
Base.show(io::IO, ::UniversalIntervalRelation{:D})      = print(io, "[D]")
Base.show(io::IO, ::UniversalIntervalRelation{:B})      = print(io, "[B]")

Base.show(io::IO, ::UniversalIntervalRelation{:InvL})   = print(io, "[InvL]")
Base.show(io::IO, ::UniversalIntervalRelation{:InvA})   = print(io, "[InvA]")
Base.show(io::IO, ::UniversalIntervalRelation{:InvO})   = print(io, "[InvO]")
Base.show(io::IO, ::UniversalIntervalRelation{:InvE})   = print(io, "[InvE]")
Base.show(io::IO, ::UniversalIntervalRelation{:InvD})   = print(io, "[InvD]")
Base.show(io::IO, ::UniversalIntervalRelation{:InvB})   = print(io, "[InvB]")

using ExprRules

G = @grammar begin
    S = ExistentialIntervalRelation{:G}(F) | UniversalIntervalRelation{:G}(F)
    F = ExistentialIntervalRelation{:L}(and(F,F))
    F = UniversalIntervalRelation{:L}(implies(F,F))
    F = implies(F,F)
    F = and(F,F)
    F = p(sum, A, ≤, a)
    A = "fever"
    # F = 1
    F = H
    H = 0.0 | 0.25 | 0.5 | 0.75 | 1.0
    a = |([i for i in 1:10])
end

p(f::Function, A, ≤, a) = Base.repr("f(A) ≤ a")
implies(a::Float64, b::Float64) = a ≤ b ? float(1) : b
and(a::Float64, b::Float64) = min(a,b)

using GBDTs

using MultivariateTimeSeries
X, y = read_data_labeled(joinpath(dirname(pathof(GBDTs)), "..", "data", "auslan_youtube8"));



grammar = @grammar begin
    b = G(bvec) | F(bvec) | G(implies(bvec,bvec))
    bvec = and(bvec, bvec)
    bvec = or(bvec, bvec)
    bvec = not(bvec)
    bvec = lt(rvec, rvec)
    bvec = lte(rvec, rvec)
    bvec = gt(rvec, rvec)
    bvec = gte(rvec, rvec)
    bvec = f_lt(x, xid, v, vid)
    bvec = f_lte(x, xid, v, vid)
    bvec = f_gt(x, xid, v, vid)
    bvec = f_gte(x, xid, v, vid)
    rvec = x[xid]
    xid = |(["x_1","y_1","z_1","roll_1","pitch_1","yaw_1","thumbbend_1","forebend_1","middlebend_1","ringbend_1","littlebend_1","x_2","y_2","z_2","roll_2","pitch_2","yaw_2","thumbbend_2","forebend_2","middlebend_2","ringbend_2","littlebend_2"])
    vid = |(1:10)
end

G(v) = all(v)                                                #globally
F(v) = any(v)                                                #eventually
f_lt(x, xid, v, vid) = lt(x[xid], v[xid][vid])               #feature is less than a constant
f_lte(x, xid, v, vid) = lte(x[xid], v[xid][vid])             #feature is less than or equal to a constant
f_gt(x, xid, v, vid) = gt(x[xid], v[xid][vid])               #feature is greater than a constant
f_gte(x, xid, v, vid) = gte(x[xid], v[xid][vid])             #feature is greater than or equal to a constant

#workarounds for slow dot operators:
implies(v1, v2) = (a = similar(v1); a .= v2 .| .!v1)         #implies
not(v) = (a = similar(v); a .= .!v)                          #not
and(v1, v2) = (a = similar(v1); a .= v1 .& v2)               #and
or(v1, v2) = (a = similar(v1); a .= v1 .| v2)                #or
lt(x1, x2) = (a = Vector{Bool}(undef,length(x1)); a .= x1 .< x2)   #less than
lte(x1, x2) = (a = Vector{Bool}(undef,length(x1)); a .= x1 .≤ x2)  #less than or equal to
gt(x1, x2) = (a = Vector{Bool}(undef,length(x1)); a .= x1 .> x2)   #greater than
gte(x1, x2) = (a = Vector{Bool}(undef,length(x1)); a .= x1 .≥ x2)  #greater than or equal to

const v = Dict{String,Vector{Float64}}()
mins, maxes = minimum(X), maximum(X)
for (i,xid) in enumerate(names(X))
    v[xid] = collect(range(mins[i],stop=maxes[i],length=10))
end;

p = MonteCarlo(2, 5)

using Random; Random.seed!(1)
model = induce_tree(grammar, :b, p, X, y, 6);
