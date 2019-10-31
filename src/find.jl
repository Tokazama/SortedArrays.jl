###
### findfirst
###
Base.findfirst(f::Function, svr::SortedVector) = _findfirst(f, parent(svr), order(svr))
Base.findfirst(f::Function, svr::SortedRange) = _findfirst(f, parent(svr), order(svr))

_findfirst(f::Function, v, ::Ordering) = findfirst(f, v)

function _findfirst(f::Fix2{typeof(iswithin)}, v::AbstractVector, vo::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, minimum(f.x), lo, hi, Forward)
    @inbounds return (i > hi || !f(v[i])) ? nothing : i
end

function _findfirst(f::Fix2{typeof(iswithin)}, v::AbstractVector, vo::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, maximum(f.x), lo, hi, Reverse)
    @inbounds return (i > hi || !f(v[i])) ? nothing : i
end

function _findfirst(f::Fix2{typeof(>)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, f.x, lo, hi, Forward)
    if i > hi
        return nothing
    elseif f(@inbounds(v[i]))
        return i
    elseif i != hi
        return i + one(T)
    else
        return nothing
    end
end

function _findfirst(f::Fix2{typeof(>=)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, f.x, lo, hi, Forward)
    @inbounds return (i > hi || !f(v[i])) ? nothing : i
end

function _findfirst(f::Fix2{typeof(<=)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, f.x, lo, hi, Reverse)
    @inbounds return (i > hi || !f(v[i])) ? nothing : i
end

function _findfirst(f::Fix2{typeof(<)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, f.x, lo, hi, Reverse)
    if i > hi
        return nothing
    elseif f(@inbounds(v[i]))
        return i
    elseif i != hi
        return i + one(T)
    else
        return nothing
    end
end

function _findfirst(f::Fix2{typeof(>)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(first(v))) ? nothing : firstindex(v)
end
function _findfirst(f::Fix2{typeof(>=)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(first(v))) ? nothing : firstindex(v)
end
function _findfirst(f::Fix2{typeof(<)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(first(v))) ? nothing : firstindex(v)
end
function _findfirst(f::Fix2{typeof(<=)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    return (isempty(v) || !f(first(v))) ? nothing : firstindex(v)
end

function _findfirst(f::Fix2{typeof(==)}, v::AbstractVector, vo::Ordering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = searchsortedfirst(v, f.x, lo, hi, vo)
    @inbounds return (i > hi || !f(v[i])) ? nothing : i
end

###
### findlast
###
Base.findlast(f::Function, svr::SortedVector) = _findlast(f, parent(svr), order(svr))
Base.findlast(f::Function, svr::SortedRange) = _findlast(f, parent(svr), order(svr))
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

###
### findall
###
Base.findall(f::Function, svr::SortedVecRange) = _findall(f, parent(svr), order(svr))
Base.findall(f::Function, svr::SortedRange) = _findall(f, parent(svr), order(svr))
_findall(f, v, vo) = findall(f, v)

function _findall(f::Fix2{typeof(iswithin)}, v::AbstractVector, vo::Ordering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findlast(f, v, vo, lo, hi)
    return isnothing(i) ? Int[] : _findfirst(f, v, vo, lo, hi):i
end

function _findall(f::Fix2{typeof(<)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findlast(f, v, Forward, lo, hi)
    return isnothing(i) ? Int[] : OneTo(i)
end

function _findall(f::Fix2{typeof(<=)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findlast(f, v, Forward, lo, hi)
    return isnothing(i) ? Int[] : OneTo(i)
end

function _findall(f::Fix2{typeof(<)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findfirst(f, v, Reverse, lo, hi)
    return isnothing(i) ? Int[] : i:lastindex(v)
end

function _findall(f::Fix2{typeof(<=)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findfirst(f, v, Reverse, lo, hi)
    return isnothing(i) ? Int[] : i:lastindex(v)
end

function _findall(f::Fix2{typeof(>)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findfirst(f, v, Forward, lo, hi)
    return isnothing(i) ? Int[] : i:lastindex(v)
end

function _findall(f::Fix2{typeof(>=)}, v::AbstractVector, ::ForwardOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findfirst(f, v, Forward, lo, hi)
    return isnothing(i) ? Int[] : i:lastindex(v)
end

function _findall(f::Fix2{typeof(>)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findlast(f, v, Reverse, lo, hi)
    return isnothing(i) ? Int[] : OneTo(i)
end

function _findall(f::Fix2{typeof(>=)}, v::AbstractVector, ::ReverseOrdering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findlast(f, v, Reverse, lo, hi)
    return isnothing(i) ? Int[] : OneTo(i)
end

function _findall(f::Fix2{typeof(==)}, v::AbstractVector, vo::Ordering, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i = _findfirst(f, v, vo, lo, hi)
    return isnothing(i) ? Int[] : i:_findlast(f, v, vo, lo, hi)
end

Base.filter(f, svr::SortedVecRange) = _filter(svr, findall(f, svr))
_filter(svr::SortedVecRange, ::Nothing) = empty(svr)
_filter(svr::SortedVecRange, inds) = @inbounds(getindex(svr, inds))

# count
Base.count(f::Function, sv::SortedVector) = _count(f, parent(sv), order(sv))
Base.count(f::Function, sr::SortedRange) = _count(f, parent(sr), order(sr))

_count(f::Function, v::AbstractVector, vo, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer} = count(f, v)
function _count(f::Function, v::AbstractVector, vo::RFOrder, lo::T=firstindex(v), hi::T=lastindex(v)) where {T<:Integer}
    i1 = _findfirst(f, v, vo, lo, hi)
    isnothing(i1) ? 0 : _findlast(f, v, vo, lo, hi) - i1 + 1
end

Base.filter(f::Function, sv::SortedVector) = _filter(sv, findall(f, sv))
Base.filter(f::Function, sv::SortedRange) = _filter(sv, findall(f, sv))

_filter(sv, inds) = @inbounds(sv[inds])
