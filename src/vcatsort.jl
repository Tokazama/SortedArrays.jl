"""
    firstsegment
"""
firstsegment(x, y) = firstsegment(order(x), order(y), x, y)
function firstsegment(xo, yo, x, y)
    return _firstsegment(
        max_of_groupmin(xo, yo, x, y),
        min_of_groupmax(xo, yo, x, y),
        xo, yo, x, y
    )
end
function _firstsegment(cmin, cmax, xo::ForwardOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(<(cmin), x, xo)], y[maybe_flip(xo, yo, _findall(<(cmin), y, yo))]),
        Forward,
        IsOrdered
    )
end

function _firstsegment(cmin, cmax, xo::ReverseOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(>(cmax), x, xo)], y[maybe_flip(xo, yo, _findall(>(cmax), y, yo))]),
        Reverse,
        IsOrdered
    )
end

"""
    middlesegment
"""
middlesegment(x, y) = middlesegment(order(x), order(y), x, y)
function middlesegment(xo, yo, x, y)
    return _middlesegment(
        max_of_groupmin(xo, yo, x, y),
        min_of_groupmax(xo, yo, x, y),
        xo, yo, x, y
    )
end
function _middlesegment(cmin, cmax, xo, yo, x, y)
    @inbounds return SortedVector(
        sort(vcat(x[_findall(iswithin(cmin:cmax), x, xo)],
                  y[_findall(iswithin(cmin:cmax), y, yo)]), order=xo),
        xo,
        IsOrdered
    )
end

"""
    lastsegment
"""
lastsegment(x, y) = lastsegment(order(x), order(y), x, y)
function lastsegment(xo, yo, x, y)
    return _lastsegment(
        max_of_groupmin(xo, yo, x, y),
        min_of_groupmax(xo, yo, x, y),
        xo, yo, x, y
    )
end

function _lastsegment(cmin, cmax, xo::ReverseOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(<(cmin), x, xo)], y[maybe_flip(xo, yo, _findall(<(cmin), y, yo))]),
        Reverse,
        IsOrdered
    )
end

function _lastsegment(cmin, cmax, xo::ForwardOrdering, yo, x, y)
    @inbounds return SortedVector(
        vcat(x[_findall(>(cmax), x, xo)], y[maybe_flip(xo, yo, _findall(>(cmax), y, yo))]),
        Forward,
        IsOrdered
    )
end

"""
    vcatsort(x, y)

Returns a sorted concatenation of `x` and `y`.
"""
vcatsort(x) = _vcatsort_one(order(x), x)
_vcatsort_one(::UnorderedOrdering, x) = sort(x)
_vcatsort_one(::Ordering, x) = x

vcatsort(x, y) = _vcatsort(order(x), order(y), x, y)
function _vcatsort(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return _vcatbefore(xo, yo, x, y)
    elseif isafter(xo, yo, x, y)
        return _vcatafter(xo, yo, x, y)
    else
        return __vcatsort(
            max_of_groupmin(xo, yo, x, y),
            min_of_groupmax(xo, yo, x, y),
            xo, yo, x, y)
    end
end

function __vcatsort(cmin, cmax, xo, yo, x, y)
    return SortedVector(
        vcat(
            _firstsegment(cmin, cmax, xo, yo, x, y),
            _middlesegment(cmin, cmax, xo, yo, x, y),
            _lastsegment(cmin, cmax, xo, yo, x, y)
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
