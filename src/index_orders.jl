###
function firstsegment(cmin, cmax, ::ForwardOrdering, yo, x, y)
    if cmin == -1
    else
    end
end

### x segments
###
# first segments indices of x

_first_x_segment(cmpmin, cmpmax, xo::ForwardOrdering, yo, x, y) = _findall(cmpmin(ordmin(yo, y)), x, xo)
_first_x_segment(cmpmin, cmpmax, xo::ReverseOrdering, yo, x, y) = _findall(cmpmax(ordmax(yo, y)), x, xo)
_last_x_segment(cmpmin, cmpmax, xo::ForwardOrdering, yo, x, y ) = _findall(cmpmax(ordmax(yo, y)), x, xo)
_last_x_segment(cmpmin, cmpmax, xo::ReverseOrdering, yo, x, y ) = _findall(cmpmin(ordmin(yo, y)), x, xo)

_first_y_segment(cmpmin, cmpmax, xo::ForwardOrdering, yo, x, y) = maybe_flip(xo, yo, _findall(cmpmin(ordmin(xo, x)), y, yo))
_first_y_segment(cmpmin, cmpmax, xo::ReverseOrdering, yo, x, y) = maybe_flip(xo, yo, _findall(cmpmax(ordmax(xo, x)), y, yo))
_last_y_segment(cmpmin, cmpmax, xo::ForwardOrdering, yo, x, y ) = maybe_flip(xo, yo, _findall(cmpmax(ordmax(xo, x)), y, yo))
_last_y_segment(cmpmin, cmpmax, xo::ReverseOrdering, yo, x, y ) = maybe_flip(xo, yo, _findall(cmpmin(ordmin(xo, x)), y, yo))

function _index_orders(cmpmax, xo, yo, x, y)
    if ltmin(xo, yo, x, y)
        return _index_orders(<, cmpmax, xo, yo, x, y)
    elseif gtmin(xo, yo, x, y)
        return _index_orders(>, cmpmax, xo, yo, x, y)
    else
        return _index_orders(==, cmpmax, xo, yo, x, y)
    end
end

function _index_orders(xo, yo, x, y)
    if ltmax(xo, yo, x, y)
        return _index_orders(<, xo, yo, x, y)
    elseif gtmax(xo, yo, x, y)
        return _index_orders(>, xo, yo, x, y)
    else  # max(x) == max(y)
        return _index_orders(==, xo, yo, x, y)
    end
end

#=
_first_x_segment(cmpmin, cmpmax, ::ForwardOrdering, yo, x, y) = _forward_first_x_segment(cmpmin, yo, x, y)
_first_x_segment(cmpmin, cmpmax, ::ReverseOrdering, yo, x, y) = _reverse_first_x_segment(cmpmax, yo, x, y)

_forward_first_x_segment(::typeof(<), yo, x, y) = _findall(<(ordmin(yo, y)), x, Forward)
_forward_first_x_segment(cmpmin, yo, x, y) = nothing

_reverse_first_x_segment(::typeof(>), yo, x, y) = _findall(>(ordmax(yo, y)), x, Reverse)
_reverse_first_x_segment(cmpmax, yo, x, y) = nothing

# last segment indices of x
_last_x_segment(cmpmin, cmpmax, ::ForwardOrdering, yo, x, y) = _forward_last_x_segment(cmpmax, yo, x, y)
_last_x_segment(cmpmin, cmpmax, ::ReverseOrdering, yo, x, y) = _reverse_last_x_segment(cmpmin, yo, x, y)

_forward_last_x_segment(::typeof(>), yo, x, y) = _findall(>(ordmax(yo, y)), x, Forward)  # searchsortedfirst(x, ordmax(yo, y), Forward):lastindex(x)
_forward_last_x_segment(cmpmax, yo, x, y) = nothing

_reverse_last_x_segment(::typeof(<), yo, x, y) = _findall(<(ordmin(yo, y)), x, Reverse)  # searchsortedfirst(x, ordmin(yo, y), Reverse):lastindex(x)
_reverse_last_x_segment(cmpmin, yo, x, y) = nothing

function _xindex_orders(cmpmin, cmpmax, xo, yo, x, y)
    __xindex_orders(_first_x_segment(cmpmin, cmpmax, xo, yo, x, y),
                    _last_x_segment(cmpmin, cmpmax, xo, yo, x, y), x)
end

_xindex_firstmid(::Nothing, x) = firstindex(x)
_xindex_firstmid(findex, x) = last(findex) + 1

_xindex_lastmid(::Nothing, x) = lastindex(x)
_xindex_lastmid(lindex, x) = first(lindex) - 1

function __xindex_orders(findex, lindex, x)
    (findex, _xindex_firstmid(findex, x):_xindex_lastmid(lindex, x), lindex)
end

###
### y segment
###
# first segments indices of y
_first_y_segment(cmpmin, cmpmax, ::ForwardOrdering, ::ForwardOrdering, x, y) = _ff_first_y_segment(cmpmin, x, y)
_first_y_segment(cmpmin, cmpmax, ::ReverseOrdering, ::ForwardOrdering, x, y) = _rf_first_y_segment(cmpmax, x, y)
_first_y_segment(cmpmin, cmpmax, ::ForwardOrdering, ::ReverseOrdering, x, y) = _fr_first_y_segment(cmpmin, x, y)
_first_y_segment(cmpmin, cmpmax, ::ReverseOrdering, ::ReverseOrdering, x, y) = _rr_first_y_segment(cmpmax, x, y)

_ff_first_y_segment(cmpmin::typeof(>), x, y) = _findall(>(ordmin(Reverse, x)), y, Forward)  # firstindex(y):searchsortedlast(y, first(x), Forward)
_ff_first_y_segment(cmpmin, x, y) = nothing

_fr_first_y_segment(cmpmin::typeof(>), x, y) = lastindex(y):-1:_findfirst(>(first(x)), y, Reverse)  # lastindex(y):-1:searchsortedfirst(y, first(x), Reverse)
_fr_first_y_segment(cmpmin, x, y) = nothing

_rf_first_y_segment(cmpmax::typeof(<), x, y) = lastindex(y):-1:_findfirst(<(first(x)), y, Forward)  # lastindex(y):-1:searchsortedfirst(y, first(x), Forward)
_rf_first_y_segment(cmpmax, x, y) = nothing

_rr_first_y_segment(cmpmax::typeof(<), x, y) = firstindex(y):searchsortedlast(y, first(x), Reverse)
_rr_first_y_segment(cmpmax, x, y) = nothing


# last segment indices of y
_last_y_segment(cmpmin, cmpmax, ::ForwardOrdering, ::ForwardOrdering, x, y) = _ff_last_y_segment(cmpmax, x, y)
_last_y_segment(cmpmin, cmpmax, ::ForwardOrdering, ::ReverseOrdering, x, y) = _fr_last_y_segment(cmpmax, x, y)
_last_y_segment(cmpmin, cmpmax, ::ReverseOrdering, ::ForwardOrdering, x, y) = _rf_last_y_segment(cmpmin, x, y)
_last_y_segment(cmpmin, cmpmax, ::ReverseOrdering, ::ReverseOrdering, x, y) = _rr_last_y_segment(cmpmin, x, y)

_ff_last_y_segment(cmpmax::typeof(<), x, y) = _findall() searchsortedfirst(y, last(x), Forward):lastindex(y)
_ff_last_y_segment(cmpmax, x, y) = nothing

_fr_last_y_segment(::typeof(<), x, y) = searchsortedlast(y, last(x), Reverse):-1:firstindex(y)
_fr_last_y_segment(cmpmax, x, y) = nothing

_rf_last_y_segment(::typeof(>), x, y) = searchsortedlast(y, last(x), Forward):-1:firstindex(y)
_rf_last_y_segment(cmpmin, x, y) = nothing

_rr_last_y_segment(::typeof(>), x, y) = _findall()
searchsortedfirst(x, last(x), Reverse):lastindex(y)
_rr_last_y_segment(cmpmin, x, y) = nothing


function _yindex_orders(cmpmin, cmpmax, xo, yo, x, y)
    __yindex_orders(_first_y_segment(cmpmin, cmpmax, xo, yo, x, y),
                    _last_y_segment(cmpmin, cmpmax, xo, yo, x, y),
                    xo, yo, y)
end

__yindex_orders(findex, lindex, xo::O, yo::O, y) where {O<:Ordering} =
    (findex, _yindex_firstmid(findex, xo, yo, y):_yindex_lastmid(lindex, xo, yo, y), lindex)
__yindex_orders(findex, lindex, xo::Ordering, yo::Ordering, y) =
    (findex, _yindex_firstmid(findex, xo, yo, y):-1:_yindex_lastmid(lindex, xo, yo, y), lindex)

_yindex_firstmid(::Nothing, ::O, ::O, y) where {O<:Ordering} = firstindex(y)
_yindex_firstmid(findex, ::O, ::O, y) where {O<:Ordering} = last(findex) + 1
_yindex_firstmid(::Nothing, ::Ordering, ::Ordering, y) = lastindex(y)
_yindex_firstmid(findex, ::Ordering, ::Ordering, y) = last(findex) - 1

_yindex_lastmid(::Nothing, ::O, ::O, y) where {O<:Ordering} = lastindex(y)
_yindex_lastmid(lindex, ::O, ::O, y) where {O<:Ordering} = first(lindex) - 1
_yindex_lastmid(::Nothing, ::Ordering, ::Ordering, y) = firstindex(y)
_yindex_lastmid(lindex, ::Ordering, ::Ordering, y) = first(lindex) + 1


function _index_orders(cmpmin, cmpmax, xo, yo, x, y)
    return (_xindex_orders(cmpmin, cmpmax, xo, yo, x, y),
            _yindex_orders(cmpmin, cmpmax, xo, yo, x, y))
end

### catch non overlapping indices
function index_orders(xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    if isbefore(yo, yo, x, y)
        return ((eachindex(x), nothing, nothing,), (nothing, nothing, eachindex(y)))
    elseif isafter(xo, yo, x, y)
        return ((nothing, nothing, eachindex(x)), (eachindex(y), nothing, nothing))
    else
        return _index_orders(xo, yo, x, y)
    end
end

function index_orders(xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    if isbefore(xo, yo, x, y)
        return ((eachindex(x), nothing, nothing,), (nothing, nothing, reverse(eachindex(y))))
    elseif isafter(xo, yo, x, y)
        return ((nothing, nothing, eachindex(x)), (reverse(eachindex(y)), nothing, nothing))
    else
        return _index_orders(xo, yo, x, y)
    end
end

function index_orders(xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    if isbefore(xo, yo, x, y)
        return ((nothing, nothing, eachindex(x)), (reverse(eachindex(y)), nothing, nothing))
    elseif isafter(xo, yo, x, y)
        return ((eachindex(x), nothing, nothing,), (nothing, nothing, reverse(eachindex(y))))
    else
        return _index_orders(xo, yo, x, y)
    end
end


function index_orders(xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    if isbefore(xo, yo, x, y)
        return ((nothing, nothing, eachindex(x)), (eachindex(y), nothing, nothing))
    elseif isafter(xo, yo, x, y)
        return ((eachindex(x), nothing, nothing,), (nothing, nothing, eachindex(y)))
    else
        return _index_orders(xo, yo, x, y)
    end
end


function get_from_index_orders(indices::Tuple{Tuple{Nothing,Any,Any},Tuple{Nothing,Any,Any}}, x, y)
    get_from_index_orders((tail(first(indices)), tail(last(indices))), x, y)
end
function get_from_index_orders(indices::Tuple{Tuple{Any,Any,Any},Tuple{Nothing,Any,Any}}, x, y)
    @inbounds vcat(x[first(first(indices))], _vcatsort((tail(first(indices)), tail(last(indices))), x, y)...)
end
function get_from_index_orders(indices::Tuple{Tuple{Nothing,Any,Any},Tuple{Any,Any,Any}}, x, y)
    @inbounds vcat(y[first(last(indices))], _vcatsort((tail(first(indices)), tail(last(indices))), x, y)...)
end

function get_from_index_orders(indices::Tuple{Tuple{Any,Any},Tuple{Any,Any}}, x, y)
    @inbounds ((x[first(first(indices))],
                y[first(last(indices))]),
               get_from_index_orders((last(first(indices)), last(last(indices))), x, y)...,)
end

first_tail(indxs::Tuple{Tuple,Tuple}) = tail(first(indxs))
last_tail(indxs::Tuple{Tuple,Tuple}) = tail(last(indxs))


_next_indices(indxs::Tuple{Tuple{Any},Tuple{Any}}) = (first(first(indxs)), first(last(indxs)))
function _next_indices(indxs::Tuple{Tuple{Any,Vararg{Any}},Tuple{Any},Vararg{Any}})
    return (first(first(indxs)), first(last(indxs)))
end

function get_from_index_orders(indices::Tuple{Tuple{Nothing,Any},Tuple{Nothing,Any}}, x, y)
    get_from_index_orders((last(first(indices)), last(last(indices))), x, y)
end

get_from_index_orders(indices::Tuple{Any,Nothing}, x, y) = @inbounds (first(indices)[x],)
get_from_index_orders(indices::Tuple{Nothing,Any}, x, y) = @inbounds (first(indices)[y],)
get_from_index_orders(indices::Tuple{Nothing,Nothing}, x, y) = ()

=#
