"""
    merge(x, y)
"""
function Base.merge(x::SortedVector, y::SortedVector)
    SortedVector(sorted_merge(order(x), order(y), parent(x), parent(y)), combine(order(x), order(y)))
end

sorted_merge(x, y) = sorted_merge(order(x), order(y), x, y)


function sorted_merge(xo, yo, x, y)
    if ltmax(xo, yo, x, y)
        return _sorted_merge_cmpmax(<, xo, yo, x, y)
    elseif gtmax(xo, yo, x, y)
        return _sorted_merge_cmpmax(>, xo, yo, x, y)
    else
        return _sorted_merge_cmpmax(==, xo, yo, x, y)
    end
end

function _sorted_merge_cmpmax(f1::Function, xo, yo, x, y)
    if ltmin(xo, yo, x, y)
        return _sorted_merge(<, f1, xo, yo, x, y)
    elseif gtmin(xo, yo, x, y)
        return _sorted_merge(>, f1, xo, yo, x, y)
    else
        return _sorted_merge(==, f1, xo, yo, x, y)
    end
end

###
### first(x) < first(y)
###
function _sorted_merge(::typeof(<), ::typeof(<), xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return unsafe_stack(xo, yo, x, y)
    elseif isafter(xo, yo, x, y)
        return unsafe_stack(yo, xo, y, x)
    else
        return merge_overlapping(<, <, xo, yo, x, y)
    end
end

# y is within x
_sorted_merge(::typeof(<), ::typeof(>), xo, yo, x, y) = merge_within_to_vector(<, >, xo, yo, x, y)
function _sorted_merge(::typeof(<), ::typeof(>), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(y, x) ? copy(x) : merge_overlapping(<, >, xo, yo, x, y)
end

_sorted_merge(::typeof(<), ::typeof(==), xo, yo, x, y) = merge_within_to_vector(<, ==, xo, yo, x, y)
function _sorted_merge(::typeof(<), ::typeof(==), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(y, x) ? copy(x) : merge_overlapping(<, ==, xo, yo, x, y)
end

###
### first(x) > first(y)
###
function _sorted_merge(::typeof(>), ::typeof(>), xo, yo, x, y)
    if isafter(xo, yo, x, y)
        return unsafe_stack(>, >, xo, yo, x, y)
    else
        return merge_overlapping(>, >, xo, yo, x, y)
    end
end

# TODO double check
_sorted_merge(::typeof(>), ::typeof(<), xo, yo, x, y) = merge_within_to_vector(>, <, xo, yo, x, y)
function _sorted_merge(::typeof(>), ::typeof(<), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(x, y) ? copy(y) : merge_overlapping(>, <, xo, yo, x, y)
end

# x is within y
_sorted_merge(::typeof(>), ::typeof(==), xo, yo, x, y) = merge_within_to_vector(>, ==, xo, yo, x, y)
function _sorted_merge(::typeof(>), ::typeof(==), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(x, y) ? copy(y) : merge_overlapping(>, ==, xo, yo, x, y)
end

###
### first(x) == first(y)
###
function _sorted_merge(::typeof(==), ::typeof(>), xo, yo, x, y)
    _can_be_within(y, x) ? copy(x) : merge_within_to_vector(==, >, xo, yo, x, y)
end

_sorted_merge(::typeof(==), ::typeof(<), xo, yo, x, y) = merge_within_to_vector(==, <, xo, yo, x, y)
function _sorted_merge(::typeof(==), ::typeof(<), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(x, y) ? copy(y) : merge_overlapping(==, <, xo, yo, x, y)
end

_sorted_merge(::typeof(==), ::typeof(==), xo, yo, x, y) = merge_within_to_vector(>, ==, xo, yo, x, y)
function _sorted_merge(::typeof(==), ::typeof(==), xo, yo, x::AbstractRange, y::AbstractRange)
    if _can_be_within(x, y) # x is within y
        return copy(y)
    elseif _is_range_within(y, x) # y is within x
        return copy(x)
    else
        return merge_sort(x, y)
    end
end

function merge_overlapping(f1, f2, xo, yo, x, y)
    return vcat(
        first_hanging_segment(f1, f2, xo, yo, x, y),
        merge_sort(xo, yo,
                   getwithin(x, max_of_groupmin(f1, xo, yo, x, y), min_of_groupmax(f2, xo, yo, x, y)),
                   getwithin(y, max_of_groupmin(f1, xo, yo, x, y), min_of_groupmax(f2, xo, yo, x, y))),
        _merge_overlapping(f1, f2, xo, yo, x, y),
        last_hanging_segment(f1, f2, xo, yo, x, y)
       )
end


## first_hanging_segment
first_hanging_segment(cmpmin, cmpmax, xo::ForwardOrdering, yo, x, y) = _forward_first_hanging_segment(f1, yo, x, y)
first_hanging_segment(cmpmin, cmpmax, xo::ReverseOrdering, yo, x, y) = _reverse_first_hanging_segment(f2, yo, x, y)
_forward_first_hanging_segment(::typeof(<),  ::ForwardOrdering, x, y) = getbefore(x, first(y))
_forward_first_hanging_segment(::typeof(<),  ::ReverseOrdering, x, y) = getbefore(x, last(y))
_forward_first_hanging_segment(::typeof(>),  ::ForwardOrdering, x, y) = getbefore(y, first(x))
_forward_first_hanging_segment(::typeof(>),  ::ReverseOrdering, x, y) = reverse(getafter(y, last(x)))
_forward_first_hanging_segment(::typeof(==), ::Ordering,        x, y) = promote_type(eltype(x), eltype(y))[]

_reverse_first_hanging_segment(::typeof(<),  ::ForwardOrdering, x, y) = reverse(getafter(y, first(x)))
_reverse_first_hanging_segment(::typeof(<),  ::ReverseOrdering, x, y) = getbefore(y, first(x))
_reverse_first_hanging_segment(::typeof(>),  ::ForwardOrdering, x, y) = getafter(x, last(y))
_reverse_first_hanging_segment(::typeof(>),  ::ReverseOrdering, x, y) = getafter(x, first(y))
_reverse_first_hanging_segment(::typeof(==), ::Ordering,        x, y) = promote_type(eltype(x), eltype(y))[]


## last_hanging_segment
last_hanging_segment(f1, f2, xo::ForwardOrdering, yo, x, y) = _forward_last_hanging_segment(f2, yo, x, y)
last_hanging_segment(f1, f2, xo::ReverseOrdering, yo, x, y) = _reverse_last_hanging_segment(f1, yo, x, y)
_forward_last_hanging_segment(::typeof(<),  ::ForwardOrdering, x, y) = getafter(y, first(x))
_forward_last_hanging_segment(::typeof(<),  ::ReverseOrdering, x, y) = reverse(getbefore(y, first(x)))
_forward_last_hanging_segment(::typeof(>),  ::ForwardOrdering, x, y) = getafter(x, last(y))
_forward_last_hanging_segment(::typeof(>),  ::ReverseOrdering, x, y) = getafter(x, first(y))
_forward_last_hanging_segment(::typeof(==), ::Ordering,        x, y) = promote_type(eltype(x), eltype(y))[]

_reverse_last_hanging_segment(::typeof(<),  ::ForwardOrdering, x, y) = getafter(x, first(y))
_reverse_last_hanging_segment(::typeof(<),  ::ReverseOrdering, x, y) = getafter(x, last(y))
_reverse_last_hanging_segment(::typeof(>),  ::ForwardOrdering, x, y) = reverse(getbefore(y, last(x)))
_reverse_last_hanging_segment(::typeof(>),  ::ReverseOrdering, x, y) = getafter(y, last(x))
_reverse_last_hanging_segment(::typeof(==), ::Ordering,        x, y) = promote_type(eltype(x), eltype(y))[]

# TODO this can be optimized
merge_sort(xo, yo, x, y) = sort(unique(union(x, y)), order=xo)

"""
    mergesort!(x, y) = mergesort!(order(x), order(y), x, y)
    mergesort!(::Ordering, ::Ordering, x, y) -> x
"""
function mergesort!(xo, yo, x y)
    if isbefore(xo, yo, x, y)
        return unsafe_appendsort!(xo, yo, x, y)
    elseif isafter(xo, yo, x y)
        return unsafe_prependsort!(xo, yo, x, y)
    else
        # TODO
        return _mergesort!(xo, yo, x, y)
    end
end
mergesort!(::ForwardOrdering, ::UUOrder, x, y) =
    mergesort!(Forward, Forward, x, sort!(y))
mergesort!(::ReverseOrdering, ::UUOrder, x, y) =
    mergesort!(Reverse, Reverse, x, sort!(y, order=Reverse))
mergesort!(::UUOrder, ::ForwardOrdering, x, y) =
    mergesort!(Forward, Forward, sort!(x), y)
mergesort!(::UUOrder, ::ReverseOrdering, x, y) =
    mergesort!(Reverse, Reverse, sort!(x, order=Reverse), y)
mergesort!(x, y) = mergesort!(order(x), order(y), x, y)


###
### !
###
# <
function _mergesort!(::typeof(<), ::typeof(>), xo, yo, x, y)
    unsafe_mergesort!(findfirst(isequal(ordmin(yo, y)), x):findfirst(isequal(ordmax(yo, y)), x), eachindex(y), xo, yo, x, y)
    return x
end

function _mergesort!(::typeof(<), ::typeof(<), ::ForwardOrdering, yo, x, y)
    within_max_y_idx = searchsortedlast(y, last(x))
    unsafe_mergesort!(findfirst(isequal(ordmin(yo, y)), x):lastindex(x), firstindex(y):within_max_y_idx, xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, (within_max_y_idx+1):lastindex(y)))
    return x
end

function _mergesort!(::typeof(<), ::typeof(<), ::ReverseOrdering, yo, x, y)
    within_max_y_idx = searchsortedlast(y, last(x))
    unsafe_mergesort!(findfirst(isequal(ordmin(yo, y)), x):lastindex(x), firstindex(y):within_max_y_idx, xo, yo, x, y)
    unsafe_prependsort!(xo, yo, x, view(y, (within_max_y_idx+1):lastindex(y)))
    return x
end

function _mergesort!(::typeof(<), ::typeof(==), xo, yo, x, y)
    unsafe_mergesort!(
        findfirst(isequal(ordmin(yo, y)), x):lastindex(x),
        eachindex(y), xo, yo, x, y)
    return x
end

# >
function _mergesort!(::typeof(>), ::typeof(>), xo, yo, x, y)
    unsafe_mergesort!(
        findfirst(isequal(ordmin(yo, y)), x):findfirst(isequal(ordmax(yo, y)), x),
        eachindex(y),
        xo,
        yo,
        x,
        y
       )
    return x
end

# y is within x  TODO should the mutating version throw an error for ranges or act like sort!
_mergesort(::typeof(<), ::typeof(>), xo, yo, x, y) = merge_within_to_vector(<, >, xo, yo, x, y)
_mergesort!(::typeof(<), ::typeof(>), xo, yo, x, y) = merge_within_to_vector!(<, >, xo, yo, x, y)

_mergesort(::typeof(<), ::typeof(>), xo, yo, x::AbstractRange, y::AbstractRange) =
    _can_be_within(y, x) ? copy(x) : merge_overlapping(<, >, xo, yo, x, y)
_mergesort!(::typeof(<), ::typeof(>), xo, yo, x::AbstractRange, y::AbstractRange) =
    _can_be_within(y, x) ? x : merge_overlapping!(<, >, xo, yo, x, y)

_sorted_merge(::typeof(<), ::typeof(==), xo, yo, x, y) = merge_within_to_vector(<, ==, xo, yo, x, y)
function _sorted_merge(::typeof(<), ::typeof(==), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(y, x) ? copy(x) : merge_overlapping(<, ==, xo, yo, x, y)
end

###
### first(x) > first(y)
###
# TODO double check
_sorted_merge(::typeof(>), ::typeof(<), xo, yo, x, y) = merge_within_to_vector(>, <, xo, yo, x, y)
function _sorted_merge(::typeof(>), ::typeof(<), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(x, y) ? copy(y) : merge_overlapping(>, <, xo, yo, x, y)
end

# x is within y
_sorted_merge(::typeof(>), ::typeof(==), xo, yo, x, y) = merge_within_to_vector(>, ==, xo, yo, x, y)
function _sorted_merge(::typeof(>), ::typeof(==), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(x, y) ? copy(y) : merge_overlapping(>, ==, xo, yo, x, y)
end

###
### first(x) == first(y)
###
function _sorted_merge(::typeof(==), ::typeof(>), xo, yo, x, y)
    _can_be_within(y, x) ? copy(x) : merge_within_to_vector(==, >, xo, yo, x, y)
end

_sorted_merge(::typeof(==), ::typeof(<), xo, yo, x, y) = merge_within_to_vector(==, <, xo, yo, x, y)
function _sorted_merge(::typeof(==), ::typeof(<), xo, yo, x::AbstractRange, y::AbstractRange)
    _can_be_within(x, y) ? copy(y) : merge_overlapping(==, <, xo, yo, x, y)
end

_sorted_merge(::typeof(==), ::typeof(==), xo, yo, x, y) = merge_within_to_vector(>, ==, xo, yo, x, y)
function _sorted_merge(::typeof(==), ::typeof(==), xo, yo, x::AbstractRange, y::AbstractRange)
    if _can_be_within(x, y) # x is within y
        return copy(y)
    elseif _is_range_within(y, x) # y is within x
        return copy(x)
    else
        return merge_sort(x, y)
    end
end

function merge_overlapping(f1, f2, xo, yo, x, y)
    return vcat(
        first_hanging_segment(f1, f2, xo, yo, x, y),
        merge_sort(xo, yo,
                   getwithin(x, max_of_groupmin(f1, xo, yo, x, y), min_of_groupmax(f2, xo, yo, x, y)),
                   getwithin(y, max_of_groupmin(f1, xo, yo, x, y), min_of_groupmax(f2, xo, yo, x, y))),
        _merge_overlapping(f1, f2, xo, yo, x, y),
        last_hanging_segment(f1, f2, xo, yo, x, y)
       )
end

## non mutating version
function unsafe_mergesort(xindex, yindex, xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    y_i, state = iterate(yindex)
    @inbounds for x_i in xindex
        while y[y_i] < x[x_i]
            insert!(x, x_i, y[y_i])
            isnothing(state) && return x
            y_i, state = iterate(yindex, state)
        end
    end
    return x
end

function unsafe_mergesort!(xindex, yindex, xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    return unsafe_mergesort!(xindex, reverse(yindex), Forward, Forward, x, y)
end

function unsafe_mergesort!(xindex, yindex, xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    y_i, state = iterate(yindex)
    @inbounds for x_i in xindex
        while y[y_i] > x[x_i]
            insert!(x, x_i, y[y_i])
            isnothing(state) && return x
            y_i, state = iterate(yindex, state)
        end
    end
    return x
end
function unsafe_mergesort!(xindex, yindex, xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    return unsafe_mergesort!(xindex, reverse(yindex), Forward, Forward, x, y)
end

function unsafe_mergesort!(xindex, yindex, xo::ForwardOrdering, yo::UUOrder, x, y)
    @inbounds for y_i in yindex
        if y[y_i] > last(x)
            push!(x, y[y_i])
        else
            for x_i in xindex
                if y[y_i] < x[x_i]
                    insert!(x, x_i, y[y_i])
                else
                    break
                end
            end
        end
    end
    return x
end

function unsafe_mergesort!(xindex, yindex, xo::ReverseOrdering, yo::UUOrder, x, y)
    @inbounds for y_i in yindex
        if y[y_i] < last(x)
            push!(x, y[y_i])
        else
            for x_i in xindex
                if y[y_i] > x[x_i]
                    insert!(x, x_i, y[y_i])
                else
                    break
                end
            end
        end
    end
    return x
end

