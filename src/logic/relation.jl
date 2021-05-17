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
struct IdentityIntervalRelation         <: AbstractIntervalRelation
    algebra::AbstractAlgebra
end
# Using the singleton design pattern; similar to Val{T}.
struct ExistentialIntervalRelation{T}   <: AbstractExistentialIntervalRelation
    algebra::AbstractAlgebra
end
ExistentialIntervalRelation(s::AbstractString,a::AbstractAlgebra)  = ExistentialIntervalRelation{Symbol(s)}(a)
ExistentialIntervalRelation(s::Symbol,a::AbstractAlgebra)          = ExistentialIntervalRelation{s}(a)
struct UniversalIntervalRelation{T}     <: AbstractUniversalIntervalRelation
    algebra::AbstractAlgebra
end
UniversalIntervalRelation(s::AbstractString,a::AbstractAlgebra)    = UniversalIntervalRelation{Symbol(s)}(a)
UniversalIntervalRelation(s::Symbol,a::AbstractAlgebra)            = UniversalIntervalRelation{s}(a)

# TODO disable r.algebra
# TODO extend to higher types (in the hierarchy); e.g., AbstractModalRelation
algebra(r::AbstractIntervalRelation) = getproperty(r, :algebra)

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


# ##
# # TODO not necessary?
# function check_relation(r::RT, os::NTuple{2,OT}) where {RT,OT}
#     check_relation(OntologicalTrait(RT), OntologicalTrait(OT), r, os)
# end
#
# function check_relation(::IntervalTrait, ::IntervalTrait, r::AbstractIntervalRelation, os::NTuple{2,Interval})
#     if iscrisp(algebra(r))
#         check_crisp_relation(IntervalTrait(), r, os)
#     else
#         check_fuzzy_relation(IntervalTrait(), r, os)
#     end
# end
#
# # TODO it is cumbersome: could be made better?
#
# function check_crisp_relation(::IntervalTrait, r::AbstractIntervalRelation, os::NTuple{2,Interval})
#     check_crisp_relation(r, os)
# end
#
# function check_fuzzy_relation(::IntervalTrait, r::AbstractIntervalRelation, os::NTuple{2,Interval})
#     check_fuzzy_relation(r, os)
# end
#
# # TODO it is cumbersome: os[1].y.x blah..
# # TODO aprire le tuple cosi posso scambiare i due intervalli per le relazioni inverse
#
# function check_crisp_relation(::ExistentialIntervalRelation{:L}, os::NTuple{2,Interval})
#     return os[1].y.x < os[2].x.x ? 1.0 : 0.0
# end
#
# function check_crisp_relation(::ExistentialIntervalRelation{:A}, os::NTuple{2,Interval})
#     return os[1].y.x = os[2].x.x ? 1.0 : 0.0
# end
#
# # function check_crisp_relation(::ExistentialIntervalRelation{:O}, os::NTuple{2,Interval})
# #     return os[1].x.x < os[2].x.x && os[2].x.x < os[1].y.x &&
# # end
#
# function check_fuzzy_relation(::ExistentialIntervalRelation{:L}, os::NTuple{2,Interval})
#     return <̃ₕ(os[1].y.x, os[2].x.x)
# end
#
#
# # my_f(f, a) = "hahaha"
# # my_f(f::typeof(sum), a) = sum(a)
# # my_f(f::typeof(sum), a; gamma=0.7) = "haha !! gamma!!"
# #
# # my_min(f, a) = "default min"
# # my_min(f::typeof(min), a; gamma=0.7) = g(a; gamma)
# #
# # g(a; gamma=0.7) = "min with gamma = $gamma"
