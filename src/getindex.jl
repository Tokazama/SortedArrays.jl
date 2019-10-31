# TODO document what this does and why
@propagate_inbounds function sorted_getindex(v, inds)
    return sorted_getindex(order(v), order(inds), v, inds)
end

@propagate_inbounds function sorted_getindex(vo, indso, v, inds)
    return getindex(v, inds), combine_getindex_orders(vo, indso)
end

function sorted_checkindex(vo, indso, v, inds)
    if ordmin(indso, inds) < firstindex(v) || ordmax(indso, inds) > lastindex(v)
        return false
    else
        return true
    end
end

# Note: can't use promote because this is order dependent
# (the `inds` of `getindex(x, inds)` determines the resulting order)
combine_getindex_orders(::ForwardOrdering,   ::ForwardOrdering  ) = Forward
combine_getindex_orders(::ReverseOrdering,   ::ReverseOrdering  ) = Forward
combine_getindex_orders(::ForwardOrdering,   ::ReverseOrdering  ) = Reverse
combine_getindex_orders(::ReverseOrdering,   ::ForwardOrdering  ) = Reverse
combine_getindex_orders(::UnorderedOrdering, ::RFOrder          ) = Unordered
combine_getindex_orders(::RFOrder,           ::UnorderedOrdering) = Unordered
combine_getindex_orders(::UnorderedOrdering, ::UnorderedOrdering) = Unordered
combine_getindex_orders(::UnkownOrdering,    ::Ordering         ) = UnkownOrder
combine_getindex_orders(::Ordering,          ::UnkownOrdering   ) = UnkownOrder


function Base.getindex(sv::SortedVector, i)
    @boundscheck checkbounds(sv, i)
    @inbounds _vec_getindex(combine_getindex_orders(order(sv), order(i)),
                            getindex(parent(sv), i))
end

_vec_getindex(xo, x) = x
_vec_getindex(xo::UUOrder, x::AbstractVector) = x
_vec_getindex(xo::Ordering, x::AbstractVector) = SortedVector(x, xo, IsSorted)

function Base.getindex(sr::SortedRange, i)
    @boundscheck checkbounds(sr, i)
    @inbounds _range_getindex(combine_getindex_orders(order(sr), order(i)),
                              getindex(parent(sr), i))
end

_range_getindex(xo, x) = x
_range_getindex(xo::UUOrder, x::AbstractVector) = x
_range_getindex(xo::Ordering, x::AbstractVector) = SortedVector(x, xo, IsSorted)
_range_getindex(xo::Ordering, x::AbstractRange) = SortedRange(x, xo, IsSorted)


