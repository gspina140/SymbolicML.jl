abstract type AlgebraicTrait end
struct CrispTrait <: AlgebraicTrait end
struct FuzzyTrait <: AlgebraicTrait end

"""
Sono in dubbio..
Ho un'idea: Mettere tipo ExistentialIntervalRelation{R,A} dove R è il tipo di relazione (:L, :A, ecc.)
e A è il tipo di algebra (:Boolean, :HeytingChain), però questo non fa emergere l'algebra.. uff...

ho risolto facendo
struct ExistentialIntervalRelation{T}   <: AbstractExistentialIntervalRelation
    algebra::AbstractAlgebra
end
"""

"""
TODO devo cambiare questo? cioè, devo fare i trait crips/fuzzy sulle relazioni/proposizioni? adesso è sulle algebre
"""
# Default behavior is crisp.
AlgebraicTrait(::Type) = CrispTrait()
AlgebraicTrait(::Type{<:BooleanAlgebra}) = CrispTrait()
AlgebraicTrait(::Type{<:HeytingAlgebra}) = FuzzyTrait()

iscrisp(x::T) where {T} = iscrisp(AlgebraicTrait(T), x)
iscrisp(::CrispTrait, x) = true
iscrisp(::FuzzyTrait, x) = false
isfuzzy(x::T) where {T} = !iscrisp(x)

abstract type OntologicalTrait end
struct PropositionalTrait   <: OntologicalTrait end
struct PointTrait           <: OntologicalTrait end
struct IntervalTrait        <: OntologicalTrait end
struct RectangleTrait       <: OntologicalTrait end
struct CubeTrait            <: OntologicalTrait end

# Default behavior is propositional.
OntologicalTrait(::Type) = PropositionalTrait()
# Propositional trait.
# OntologicalTrait(::Type{<:PropositionalState})              = PropositionalTrait()
OntologicalTrait(::Type{<:AbstractPropositionalRelation})   = PropositionalTrait()
# Point trait.
# OntologicalTrait(::Type{<:Point})                           = PointTrait()
OntologicalTrait(::Type{<:AbstractPointRelation})           = PointTrait()
# Interval trait.
OntologicalTrait(::Type{<:Interval})                        = IntervalTrait()
OntologicalTrait(::Type{<:AbstractIntervalRelation})        = IntervalTrait()
# Rectangle trait.
# OntologicalTrait(::Type{<:Rectangle})                       = RectangleTrait()
OntologicalTrait(::Type{<:AbstractRectangleRelation})       = RectangleTrait()
# Cube trait.
# OntologicalTrait(::Type{<:Cube})                            = CubeTrait()
OntologicalTrait(::Type{<:AbstractCubeRelation})            = CubeTrait()

# Is modal relation only if it is not propositional.
ismodal_relation(x::T) where {T}            = ismodal_relation(OntologicalTrait(T), x)
ismodal_relation(::PropositionalTrait, x)   = false
ismodal_relation(::PointTrait, x)           = true
ismodal_relation(::IntervalTrait, x)        = true
ismodal_relation(::RectangleTrait, x)       = true
ismodal_relation(::CubeTrait, x)            = true


# check_relation(r::T, os::NTuple{2, AbstractOntology}) where {T} = check_relation(OntologicalTrait(T), r, os)
# function check_relation(::IntervalTrait, r, os)
#     @show r
#     @show os
# end

function check_relation(r::T, o1::S1, o2::S2) where {T,S1,S2}
    check_relation(OntologicalTrait(T), OntologicalTrait(S1), OntologicalTrait(S2), r, o1, o2)
end
function check_relation(::IntervalTrait, ::IntervalTrait, ::IntervalTrait, r, o1, o2)
    @show r
    @show o1
    @show o2
    nothing
end

# check_relation(r::T, os::NTuple{2, AbstractOntology}) where {T} = check_relation(OntologicalTrait(T), r, os)

# function check_relation(::IntervalTrait, r, os)
#     @show r
#     @show os
# end
