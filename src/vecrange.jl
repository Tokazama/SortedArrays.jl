
const SortedVecRange{T,P,O} = Union{SortedRange{T,P,O},SortedVector{T,P,O}}

Base.size(sv::SortedVecRange) = size(parent(sv))
Base.size(sv::SortedVecRange, i) = size(parent(sv), i)

Base.axes(sv::SortedVecRange) = axes(parent(sv))
Base.axes(sv::SortedVecRange, i) = axes(parent(sv), i)

Base.length(sv::SortedVecRange) = length(parent(sv))

Base.first(sv::SortedVecRange) = first(parent(sv))

Base.last(sv::SortedVecRange) = last(parent(sv))

Base.firstindex(sv::SortedVecRange) = firstindex(parent(sv))

Base.lastindex(sv::SortedVecRange) = lastindex(parent(sv))

function Base.checkindex(::Type{Bool}, sv::SortedRange, inds::AbstractVector)
    return sorted_checkindex(order(sv), order(inds), sv, inds)
end

Base.checkindex(::Type{Bool}, vr::SortedVecRange, i) = checkindex(Bool, parent(r), i)

function Base.getindex(vr::SortedVecRange, i)
    @boundscheck checkbounds(vr, i)
    @inbounds _maybe_sorted(vr, sorted_getindex(order(vr), order(i), parent(vr), i))
end

function _maybe_sorted(sv::SortedVector, vec_and_ord::Tuple{AbstractVector,Ordering})
    return SortedVector(first(vec_and_ord), last(vec_and_ord), IsSorted)
end

function _maybe_sorted(sv::SortedRange, vec_and_ord::Tuple{AbstractVector,Ordering})
    return SortedRange(first(vec_and_ord), last(vec_and_ord), IsSorted)
end

_maybe_sorted(::SortedVecRange, vec_and_ord::Tuple{Any,Ordering}) = first(vec_and_ord)

function Base.append!(x::SortedVecRange, y::SortedVecRange)
    sorted_append!(order(x), order(y), parent(x), parent(y))
    return x
end

isgrowable(::Type{<:SortedVecRange{T,P,O}}) where {T,P,O} = isgrowable(P)
can_growfirst(::Type{<:SortedVecRange{T,P,O}}) where {T,P,O} = can_growfirst(P)
can_growlast(::Type{<:SortedVecRange{T,P,O}}) where {T,P,O} = can_growfirst(P)

function growlast!(vr::SortedVecRange, i)
    _growlast!(order(vr), parent(vr), i)
    return vr
end
