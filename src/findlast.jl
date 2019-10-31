
_findlast(f, v, ::Ordering) = findlast(f, v)

function _findlast(f::Fix2{typeof(iswithin)}, v::AbstractVector, vo::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return _findlast(<=(maximum(f.x)), v, vo, lo, hi)
    #i = searchsortedlast(v, maximum(f.x), lo, hi, Forward)
    #@inbounds return (i < lo || !f(v[i])) ? nothing : i
end

function _findlast(f::Fix2{typeof(iswithin)}, v::AbstractVector, vo::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return _findlast(>=(minimum(f.x)), v, vo, lo, hi)
    #i = searchsortedlast(v, minimum(f.x), lo, hi, Reverse)
    #@inbounds return (i < lo || !f(v[i])) ? nothing : i
end

function _findlast(f::Fix2{typeof(<)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedlast(v, f.x, lo, hi, Forward)
    @inbounds if i < lo
        return nothing
    elseif f(v[i])
        return i
    elseif i != lo
        return i - 1
    end
end

function _findlast(f::Fix2{typeof(>)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(last(v))) ? nothing : hi
end

function _findlast(f::Fix2{typeof(>=)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(last(v))) ? nothing : hi
end

function _findlast(f::Fix2{typeof(<=)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedlast(v, f.x, lo, hi, Forward)
    @inbounds return (i < lo || !f(v[i])) ? nothing : i
end

function _findlast(f::Fix2{typeof(>)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedlast(v, f.x, lo, hi, Reverse)
    @inbounds if i < lo
        return nothing
    elseif f(v[i])
        return i
    elseif i != lo
        return i - 1
    end
end

function _findlast(f::Fix2{typeof(>=)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedlast(v, f.x, lo, hi, Reverse)
    @inbounds return (i < lo || !f(v[i])) ? nothing : i
end

function _findlast(f::Fix2{typeof(<)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(last(v))) ? nothing : hi
end

function _findlast(f::Fix2{typeof(<=)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(last(v))) ? nothing : hi
end

function _findlast(f::Fix2{typeof(==)}, v::AbstractVector, vo::Ordering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedlast(v, f.x, lo, hi, vo)
    @inbounds return (i > hi || !f(v[i])) ? nothing : i
end
