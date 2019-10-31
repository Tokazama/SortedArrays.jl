const SortedVecRange{T,P,O} = Union{SortedRange{T,P,O},SortedVector{T,P,O}}

isgrowable(::Type{SortedVector{T,P,O}}) where {T,P,O} = isgrowable(P)

function growlast!(v::SortedVector, i)
    isgrowable(v) || error("Type $(typeof(v)) cannot grow.")
    unsafe_growlast!(order(v), parent(v), i)
    return v
end
#isgrowable(::Type{SortedRange{T,P,O}}) where {T,P,O} = isgrowable(P)

ordfindmax(svr::SortedVecRange) = ordfindmax(order(svr), parent(svr))
ordfindmin(svr::SortedVecRange) = ordfindmax(order(svr), parent(svr))

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

function Base.append!(x::SortedVecRange, y::SortedVecRange)
    sorted_append!(order(x), order(y), parent(x), parent(y))
    return x
end

Base.findmin(svr::SortedVecRange) = ordfindmin(svr)

Base.findmax(svr::SortedVecRange) = ordfindmax(svr)

Base.maximum(svr::SortedVecRange) = ordmax(order(svr), parent(svr))

Base.minimum(svr::SortedVecRange) = ordmin(order(svr), parent(svr))

Base.searchsortedfirst(svr::SortedVecRange, val) =
    _searchsortedfirst(order(svr), parent(x), val)
_searchsortedfirst(xo::Ordering, x, val) =
    searchsortedfirst(x, val, ordmin(xo, x), ordmax(xo, x), xo)
_searchsortedfirst(::UUOrder, x, val) = searchsortedfirst(x, val)

Base.searchsortedlast(svr::SortedVecRange, val) =
    _searchsortedlast(order(svr), parent(x), val)
_searchsortedlast(xo::Ordering, x, val) =
    searchsortedlast(x, val, ordmin(xo, x), ordmax(xo, x), xo)
_searchsortedlast(::UUOrder, x, val) = searchsortedlast(x, val)

Base.findfirst(f, x::SortedVector) = ordfindfirst(f, parent(x))
