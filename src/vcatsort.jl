"""
    first_segment
"""
first_segment(x, y) = first_segment(order(x), order(y), x, y)
function first_segment(xo, yo, x, y)
    return _first_segment(
        max_of_groupmin(xo, yo, x, y),
        min_of_groupmax(xo, yo, x, y),
        xo, yo, x, y
    )
end
function _first_segment(cmin, cmax, xo::ForwardOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(<(cmin), x, xo)], y[maybe_flip(xo, yo, _findall(<(cmin), y, yo))]),
        Forward,
        IsOrdered
    )
end

function _first_segment(cmin, cmax, xo::ReverseOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(>(cmax), x, xo)], y[maybe_flip(xo, yo, _findall(>(cmax), y, yo))]),
        Reverse,
        IsOrdered
    )
end

"""
    middle_segment
"""
middle_segment(x, y) = middle_segment(order(x), order(y), x, y)
function middle_segment(xo, yo, x, y)
    return _middle_segment(
        max_of_groupmin(xo, yo, x, y),
        min_of_groupmax(xo, yo, x, y),
        xo, yo, x, y
    )
end
function _middle_segment(cmin, cmax, xo, yo, x, y)
    @inbounds return SortedVector(
        sort(vcat(x[_findall(iswithin(cmin:cmax), x, xo)],
                  y[_findall(iswithin(cmin:cmax), y, yo)]), order=xo),
        xo,
        IsOrdered
    )
end

"""
    last_segment
"""
last_segment(x, y) = last_segment(order(x), order(y), x, y)
function last_segment(xo, yo, x, y)
    return _last_segment(
        max_of_groupmin(xo, yo, x, y),
        min_of_groupmax(xo, yo, x, y),
        xo, yo, x, y
    )
end

function _last_segment(cmin, cmax, xo::ReverseOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(<(cmin), x, xo)], y[maybe_flip(xo, yo, _findall(<(cmin), y, yo))]),
        Reverse,
        IsOrdered
    )
end

function _last_segment(cmin, cmax, xo::ForwardOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(>(cmax), x, xo)], y[maybe_flip(xo, yo, _findall(>(cmax), y, yo))]),
        Forward,
        IsOrdered
    )
end

"""
    vcat_sort(x, y)

Returns a sorted concatenation of `x` and `y`.
"""
vcat_sort(x) = _vcat_sort_one(order(x), x)
_vcat_sort_one(::UnorderedOrdering, x) = sort(x)
_vcat_sort_one(::Ordering, x) = x

vcat_sort(x, y) = _vcat_sort(order(x), order(y), x, y)
function _vcat_sort(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return _vcatbefore(xo, yo, x, y)
    elseif isafter(xo, yo, x, y)
        return _vcatafter(xo, yo, x, y)
    else
        return __vcat_sort(
            max_of_groupmin(xo, yo, x, y),
            min_of_groupmax(xo, yo, x, y),
            xo, yo, x, y)
    end
end

function __vcat_sort(cmin, cmax, xo, yo, x, y)
    return SortedVector(
        vcat(
            _first_segment(cmin, cmax, xo, yo, x, y),
            _middle_segment(cmin, cmax, xo, yo, x, y),
            _last_segment(cmin, cmax, xo, yo, x, y)
        ),
        xo,
        IsOrdered
    )
end

function _vcatbefore(xo, yo, x, y)
    if isforward(xo)
        return SortedVector(isforward(yo) ? vcat(x, y) : vcat(x, reverse(y)), xo, IsOrdered)
    else
        return SortedVector(isforward(yo) ? vcat(reverse(y), x) : vcat(y, x), xo, IsOrdered)
    end
end

function _vcatafter(xo, yo, x, y)
    if isforward(xo)
        return SortedVector(isforward(yo) ? vcat(y, x) : vcat(reverse(y), x), xo, IsOrdered)
    else
        return SortedVector(isforward(yo) ? vcat(x, reverse(y)) : vcat(x, y), xo, IsOrdered)
    end
end
