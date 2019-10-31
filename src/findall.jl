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

