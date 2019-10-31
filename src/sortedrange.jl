
"""
    SortedRange

A range with it's order of sorting known at compile time.
"""
struct SortedRange{T,P<:AbstractRange{T},O} <: AbstractRange{T}
    _parent::P

    function SortedRange{T,P,O}(p::P, ::NotSortedTrait) where {T,P,O}
        issorted(p, order=O) || error("Order is specified as $O but provided container is not that order.")
        return new{T,P,O}(p)
    end

    # skip sorting if we checked in previous method
    SortedRange{T,P,O}(p::P, ::IsSortedTrait) where {T,P,O} = new{T,P,O}(p)
end

const ForwardRange{T,P} = SortedRange{T,P,Forward}
const ReverseRange{T,P} = SortedRange{T,P,Reverse}

SortedRange(sv::SortedRange) = sv

function SortedRange(vec_ord::Tuple{AbstractVector,Ordering})
    return SortedRange(first(vec_ord), last(vec_ord), IsSorted)
end

SortedRange(v::AbstractVector) = SortedRange(v, order(v), IsSorted)
function SortedRange(v::AbstractVector, o::Ordering, sorted_state::SortedTrait=NotSorted)
    return SortedRange{eltype(v),typeof(v),o}(v, sorted_state)
end

Base.parent(sv::SortedRange) = getfield(sv, :_parent)
Base.step(sv::SortedRange) = step(parent(sv))
order(::Type{SortedRange{T,P,O}}) where {T,P,O} = O

isforward(::SortedRange{T,P,Forward}) where {T,P} = true
isforward(::SortedRange{T,P,O}) where {T,P,O} = false

isreverse(::SortedRange{T,P,Reverse}) where {T,P} = true
isreverse(::SortedRange{T,P,O}) where {T,P,O} = false

Base.reverse(sv::ReverseRange) = SortedRange(reverse(parent(sv)), Forward, IsSorted)
Base.reverse(sv::ForwardRange) = SortedRange(reverse(parent(sv)), Reverse, IsSorted)

StaticRanges.can_setfirst(::Type{SortedRange{T,P,O}}) where {T,P,O} = can_setfirst(P)
StaticRanges.can_setstep(::Type{SortedRange{T,P,O}}) where {T,P,O} = can_setstep(P)
StaticRanges.can_setlast(::Type{SortedRange{T,P,O}}) where {T,P,O} = can_setlast(P)
StaticRanges.can_setlength(::Type{SortedRange{T,P,O}}) where {T,P,O} = can_setlength(P)

