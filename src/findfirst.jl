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

