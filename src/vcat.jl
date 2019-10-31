
maybe_flip(xo::O, yo::O, inds) where {O<:Ordering} = inds
maybe_flip(xo::Ordering, yo::Ordering, inds) = reverse(inds)

function firstsegment(cmin, cmax, xo::ForwardOrdering, yo, x, y)
    @inbounds vcat(x[_findall(<(cmin), x, xo)], y[maybe_flip(xo, yo, _findall(<(cmin), y, yo))])
end

function firstsegment(cmin, cmax, xo::ReverseOrdering, yo, x, y)
    @inbounds vcat(x[_findall(>(cmax), x, xo)], y[maybe_flip(xo, yo, _findall(>(cmax), y, yo))])
end

function middlesegment(cmin, cmax, xo, yo, x, y)
    @inbounds sort(vcat(x[_findall(iswithin(cmin:cmax), x, xo)],
                        y[_findall(iswithin(cmin:cmax), y, yo)]), order=xo)
end

function lastsegment(cmin, cmax, xo::ReverseOrdering, yo, x, y)
    @inbounds vcat(x[_findall(<(cmin), x, xo)], y[maybe_flip(xo, yo, _findall(<(cmin), y, yo))])
end

function lastsegment(cmin, cmax, xo::ForwardOrdering, yo, x, y)
    @inbounds vcat(x[_findall(>(cmax), x, xo)], y[maybe_flip(xo, yo, _findall(>(cmax), y, yo))])
end

"""
    vcatsort(x, y)
"""
vcatsort(x) = _vcatsort_one(order(x), x)
_vcatsort_one(::UnorderedOrdering, x) = sort(x)
_vcatsort_one(::Ordering, x) = x


vcatsort(x, y) = _vcatsort(order(x), order(y), x, y)
function _vcatsort(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        if isforward(xo)
            return isforward(yo) ? vcat(x, y) : vcat(x, reverse(y))
        else
            return isforward(yo) ? vcat(reverse(y), x) : vcat(y, x)
        end
    elseif isafter(xo, yo, x, y)
        if isforward(xo)
            return isforward(yo) ? vcat(y, x) : vcat(reverse(y), x)
        else
            return isforward(yo) ? vcat(x, reverse(y)) : vcat(x, y)
        end
    else
        return __vcatsort(
            max_of_groupmin(xo, yo, x, y),
            min_of_groupmax(xo, yo, x, y),
            xo, yo, x, y)
    end
end

function __vcatsort(cmin, cmax, xo, yo, x, y)
    return vcat(
        firstsegment(cmin, cmax, xo, yo, x, y),
        middlesegment(cmin, cmax, xo, yo, x, y),
        lastsegment(cmin, cmax, xo, yo, x, y)
    )
end

"""
    mergesort!(x, y)
"""
mergesort!(x, y) = _getindex_and_mergesort!(order(x), order(y), x, y)
_getindex_and_mergesort!(xo, yo, x, y) = _mergesort!(index_orders(xo, yo, x, y), xo, yo, x, y)

function __mergesort!(idxs::Tuple{Tuple})
end


function _mergesort!(idxs::Tuple{Tuple{Any,Any,Nothing},Tuple{Any,Any,Any}}, xo, x, y)
    for i in last(last(idxs))
        push!(x, @inbounds(y[i]))
    end
    return _mergesort!((front(first(idxs)), front(last(idxs))), xo, x, y)
end
function _mergesort!(idxs::Tuple{Tuple{Any,Any,Any},Tuple{Any,Any,Nothing}}, xo, x, y)
    return _mergesort!((first_tail(idxs), last_tail(idxs)), xo, x, y)
end

function _mergesort!(idxs::Tuple{Tuple{Any,Nothing},Tuple{Any,Nothing}}, xo, x, y)
    return _mergesort!((front(first(idxs)), front(last(idxs))), x, y)
end

function _mergesort!(idxs::Tuple{Tuple{Any,Any},Tuple{Any,Any}}, xo, x, y)
    # TODO
    unsafe_mergesort!(first(first(idxs)), first(last(idxs)), xo, x, y)
    return (_mergesort!((front(first(idxs)), front(last(idxs))), x, y)...,)
end
function _mergesort!(idxs::Tuple{Tuple{Nothing,Any},Tuple{Nothing,Any}}, xo, x, y)
    @inbounds return (_vcatsort((first_tail(idxs), last_tail(idxs)), x, y)...,)
end

function _mergesort!(idxs::Tuple{Tuple{Nothing},Tuple{Any}}, x, y)
    for i in last(last(idxs))
        pushfirst!(x, @inbounds(y[i]))
    end
    return x
end
_mergesort!(idxs::Tuple{Tuple{Any},Tuple{Nothing}}, x, y) = x
_mergesort!(idxs::Tuple{Tuple{Nothing},Tuple{Nothing}}, x, y) = x
