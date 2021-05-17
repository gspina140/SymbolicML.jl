import Base: <

##
# Abstract ontology.
abstract type AbstractOntology end

##
# Abstract propositional ontology.
abstract type AbstractPropositionalOntology <: AbstractOntology end
# Abstract modal ontology.
abstract type AbstractModalOntology         <: AbstractOntology end

##
# Abstract temporal ontology.
abstract type AbstractTemporalOntology          <: AbstractModalOntology end
# Abstract spatial ontology.
abstract type AbstractSpatialOntology           <: AbstractModalOntology end
# Abstract spatio-temporal ontology.
abstract type AbstractSpatioTemporalOntology    <: AbstractModalOntology end

##
# Propositional state.
struct PropositionalState <: AbstractPropositionalOntology end

##
# (Temporal) Point ontology.
struct Point{T<:Int64} <: AbstractTemporalOntology
    x::T
end

const point(x) = Point(x)
# <(p::Point, q::Point) = p.x < q.x ? true : false

# (Temporal) Interval ontology.
struct Interval{T<:Int64} <: AbstractTemporalOntology
    x::Point{T}     # start point
    y::Point{T}     # end point
end

const interval(x,y) = Interval(point(x), point(y))

# (Spatial) Rectangle ontology.
struct Rectangle{T<:Int64} <: AbstractSpatialOntology
    x::Interval{T}  # first spatial dimension
    y::Interval{T}  # second spatial dimension
end

const rectangle((xx,xy),(yx,yy)) = Rectangle(interval(xx,xy), interval(yx,yy))

# (Spatio-temporal) Cube ontology.
struct Cube{S<:Int64,T<:Int64} <: AbstractSpatioTemporalOntology
    x::Interval{S}  # first spatial dimension
    y::Interval{S}  # second spatial dimension
    z::Interval{T}  # temporal dimension
end

# const cube((xx,xy),(yx,yy),(x,y)) = Cube(rectangle((xx,xy),(yx,yy)),interval(x,y))
