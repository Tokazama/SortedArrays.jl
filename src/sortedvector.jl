struct SortedVector{T,P<:AbstractVector{T},O} <: AbstractVector{T}
    _parent::P

    function SortedVector{T,P,O}(p::P, ::NotOrderedTrait) where {T,P,O}
        issorted(p, order=O) || error("Order is specified as $O but provided container is not that order.")
        return new{T,P,O}(p)
    end

    # skip sorting if we checked in previous method
    SortedVector{T,P,O}(p::P, ::IsOrderedTrait) where {T,P,O} = new{T,P,O}(p)
end

const ReverseVector{T,P} = SortedVector{T,P,Reverse}
const ForwardVector{T,P} = SortedVector{T,P,Forward}

SortedVector(sv::SortedVector) = sv

function SortedVector(vec_ord::Tuple{AbstractVector,Ordering})
    return SortedVector(first(vec_ord), last(vec_ord), IsOrdered)
end

SortedVector(v::AbstractVector) = SortedVector(v, order(v), IsOrdered)
function SortedVector(v::AbstractVector, o::Ordering, sorted_state::SortedTrait=NotOrdered)
    return SortedVector{eltype(v),typeof(v),o}(v, sorted_state)
end

Base.parent(sv::SortedVector) = getfield(sv, :_parent)
order(::Type{SortedVector{T,P,O}}) where {T,P,O} = O

isforward(::SortedVector{T,P,Forward}) where {T,P} = true
isforward(::SortedVector{T,P,O}) where {T,P,O} = false

isreverse(::SortedVector{T,P,Reverse}) where {T,P} = true
isreverse(::SortedVector{T,P,O}) where {T,P,O} = false

Base.reverse(sv::ReverseVector) = SortedVector(reverse(parent(sv)), Forward, IsOrdered)
Base.reverse(sv::ForwardVector) = SortedVector(reverse(parent(sv)), Reverse, IsOrdered)


Base.pop!(sv::SortedVector) = (pop!(parent(sv)); sv)

Base.popfirst!(sv::SortedVector) = (popfirst!(parent(sv)); sv)

Base.push!(sv::SortedVector, items...) = (push!(parent(sv), items...); sv)

Base.pushfirst!(sv::SortedVector, items...) = (pushfirst!(parent(sv), items...); sv)



