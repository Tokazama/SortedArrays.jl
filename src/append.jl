#= Mini style guide

* `unsafe_*` : the method assumes that sorting has already been determined so
    that `x` and `y` are in the proper order (e.g. unsafe_appendsort!(x, y)
    -> all of x is before y)
* `*_insert` : these assume that the pre/ap-pend action occurs somewhere within
    `x` or `y`. This allows append like behavior without copying everything or
    when similar behavior can't otherwise be performed because it would create
    a view (for which mutating methods aren't universally available
=#
# TODO - Decision
# If all the values of `x` aren't before all those of `y` then it's impossible
# to truly append and sort. In this case do we just sort the individual `x` and
# `y` then append? (current implementation)

###
### unsafe_appendsort_insert!
###
function unsafe_appendsort_insert!(xlastindex, yinds,  ::ForwardOrdering, ::ForwardOrdering, x, y)
    @inbounds for y_i in reverseind(yinds)
        insert!(x, xlastindex, y[y_i])
    end
    return x
end

function unsafe_appendsort_insert!(xlastindex, yinds, ::ReverseOrdering, ::ForwardOrdering, x, y)
    @inbounds for y_i in yinds
        insert!(x, xlastindex, y[y_i])
    end
    return x
end

function unsafe_appendsort_insert!(xlastindex, yinds, ::ForwardOrdering, ::ReverseOrdering, x, y)
    @inbounds for y_i in yinds
        insert!(x, xlastindex, y[y_i])
    end
    return x
end

function unsafe_appendsort_insert!(xlastindex, yinds,  ::ReverseOrdering, ::ReverseOrdering, x, y)
    @inbounds for y_i in reverseind(yinds)
        insert!(x, xlastindex, y[y_i])
    end
    return x
end

###
### unsafe_appendsort!
###
unsafe_appendsort!(::ForwardOrdering, ::ForwardOrdering, x, y) = append!(x, y)
unsafe_appendsort!(::ForwardOrdering, ::ReverseOrdering, x, y) = append!(x, reverse(y))
unsafe_appendsort!(::ReverseOrdering, ::ForwardOrdering, x, y) = append!(x, reverse(y))
unsafe_appendsort!(::ReverseOrdering, ::ReverseOrdering, x, y) = append!(x, y)


###
### unsafe_prependsort_insert!
###
function unsafe_prependsort_insert!(xfirstindex, yinds,  ::ForwardOrdering, ::ForwardOrdering, x, y)
    @inbounds for y_i in reverseind(yinds)
        insert!(x, xfirstindex, y[y_i])
    end
    return x
end

function unsafe_prependsort_insert!(xfirstindex, yinds, ::ReverseOrdering, ::ForwardOrdering, x, y)
    @inbounds for y_i in yinds
        insert!(x, xfirstindex, y[y_i])
    end
    return x
end

function unsafe_prependsort_insert!(xfirstindex, yinds, ::ForwardOrdering, ::ReverseOrdering, x, y)
    @inbounds for y_i in yinds
        insert!(x, xfirstindex, y[y_i])
    end
    return x
end

function unsafe_prependsort_insert!(xfirstindex, yinds,  ::ReverseOrdering, ::ReverseOrdering, x, y)
    @inbounds for y_i in reverseind(yinds)
        insert!(x, xfirstindex, y[y_i])
    end
    return x
end

###
### unsafe_prependsort!
###
unsafe_prependsort!(::ForwardOrdering, ::ForwardOrdering, x, y) = prepend!(x, y)
unsafe_prependsort!(::ForwardOrdering, ::ReverseOrdering, x, y) = prepend!(x, reverse(y))
unsafe_prependsort!(::ReverseOrdering, ::ForwardOrdering, x, y) = prepend!(x, reverse(y))
unsafe_prependsort!(::ReverseOrdering, ::ReverseOrdering, x, y) = prepend!(x, y)

"""
    appendsort!()
"""
function appendsort!(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return unsafe_appendsort!(xo, yo, x, y)
    else
        return append!(xo, yo, x, y)
    end
end
appendsort!(::ForwardOrdering, ::UUOrder, x, y) =
    appendsort!(Forward, Forward, x, sort!(y))
appendsort!(::ReverseOrdering, ::UUOrder, x, y) =
    appendsort!(Reverse, Reverse, x, sort!(y, order=Reverse))
appendsort!(::UUOrder, ::ForwardOrdering, x, y) =
    appendsort!(Forward, Forward, sort!(x), y)
appendsort!(::UUOrder, ::ReverseOrdering, x, y) =
    appendsort!(Reverse, Reverse, sort!(x, order=Reverse), y)
appendsort!(x, y) = appendsort!(order(x), order(y), x, y)

"""
    prependsort!()
"""
function prependsort!(xo, yo, x, y)
    if isafter(xo, yo, x, y)
        return unsafe_prependsort!(xo, yo, x, y)
    else
        return prepend!(xo, yo, x, y)
    end
end
prependsort!(::ForwardOrdering, ::UUOrder, x, y) =
    prependsort!(Forward, Forward, x, sort!(y))
prependsort!(::ReverseOrdering, ::UUOrder, x, y) =
    prependsort!(Reverse, Reverse, x, sort!(y, order=Reverse))
prependsort!(::UUOrder, ::ForwardOrdering, x, y) =
    prependsort!(Forward, Forward, sort!(x), y)
prependsort!(::UUOrder, ::ReverseOrdering, x, y) =
    prependsort!(Reverse, Reverse, sort!(x, order=Reverse), y)
prependsort!(x, y) = prependsort!(order(x), order(y), x, y)



# TODO range appending, non mutating appends
#=
#Base.union!(x::SortedVector, y::SortedVector) = mergesort!(findorder(x), findorder(y), x, y)

function Base.append!(x::SortedVector, y::SortedVector)
    return appendsort!(order(x), order(y), parent(x), parent(y))
end

function Base.append!(x::SortedVector, y::AbstractVector)
    return appendsort!(order(x), order(y), parent(x), y)
end

Base.append!(x::AbstractVector, y::SortedVector) = append!(x, parent(y))

"""
    appendsort!(x, y) -> (x, ::Order)

Append `y` to `x` and ensure the `x` that the return of `order(x)` remains the
same.
"""
appendsort!(x, y) = appendsort!(order(x), order(y), x, y)

function appendsort!(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return unsafe_appendsort!(xo, yo, x, y)
    else
        return maybe_sort!(xo, append!(x, y))
    end
end

function appendsort!(xo, yo, x::SortedVector, y)
    if isbefore(xo, yo, x, y)
        # unsafe_appendsort! assumes it's already in the right order
        return unsafe_appendsort!(xo, yo, parent(x), y)
    else
        return sort!(append!(parent(x), y), order=xo)
    end
end

appendsort!(xo, yo, x::SortedVector, y) = appendsort!(xo, yo, parent(x), y)

maybe_sort!(::UUOrder, x) = x

maybe_sort!(xo::UUOrder, x) = sort!(x, order=xo)


# mutable stack
unsafe_stack(::ForwardOrdering, ::ForwardOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == first(y)) ? _stack_range(xo, yo, x, y) : vcat(x, y)

unsafe_stack(::ForwardOrdering, ::ReverseOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == last(y)) ? _stack_range(xo, yo, x, y) : vcat(x, y)

unsafe_stack(xo::ReverseOrdering, yo::ForwardOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == last(y)) ? _stack_range(xo, yo, x, y) : vcat(x, reverse(y))

unsafe_stack(::ReverseOrdering, ::ReverseOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == first(y)) ? _stack_range(xo, yo, x, y) : vcat(x, y)

_stack_range(xo, yo, x::AbstractUnitRange, y) = typeof(x)(first(x), last(y))

_stack_range(xo, yo, x::OrdinalRange, y) = typeof(x)(first(x), step(x), last(y))

_stack_range(xo, yo, x::AbstractRange, y) = first(x):step(x):last(y)

_stack_range!(::ForwardOrdering, yo, x::MRange, y) = (setlast!(x, last(y)): x)

function unsafe_appendsort!(::Ordering, ::Ordering, x::AbstractRange, y::AbstractRange)
    return growlast!(x, length(y))
end
=#
