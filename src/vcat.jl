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
