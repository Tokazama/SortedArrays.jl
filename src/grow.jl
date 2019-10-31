"""
    isgrowable(x) -> Bool

Returns `true` if `x` can grow. In this context "grow" means that the
container `x` can be mutated to store additional elements. Types that return
`true` should be compatible with methods such as `push!` and `append!`.
"""
isgrowable(::T) where {T} = isgrowable(T)
isgrowable(::Type{T}) where {T} = false
isgrowable(::Type{T}) where {T<:Vector} = true
isgrowable(::Type{LinearIndices{1,Tuple{T}}}) where {T} = isgrowable(T)
isgrowable(::Type{CartesianIndices{1,Tuple{T}}}) where {T} = isgrowable(T)
isgrowable(::Type{T}) where {T<:BitArray{1}} = true
isgrowable(::Type{T}) where {T<:BitSet} = true
isgrowable(::Type{T}) where {T<:Dict} = true
isgrowable(::Type{T}) where {T<:Set} = true
isgrowable(::Type{T}) where {T<:Base.IdSet} = true
isgrowable(::Type{T}) where {T<:CompositeException} = true
isgrowable(::Type{T}) where {T<:Channel} = true

function isgrowable_or_error(::X) where {X}
    isgrowable(X) || errore("Types of $X cannot be resized.")
    return nothing
end


"""
    growlast!(a, i) -> a

Requires that `a` is a subtype of `AbstractRange` or is a vector containing
random generatable eltypes.
"""
function growlast!(v, i)
    isgrowable(v) || error("Type $(typeof(v)) cannot grow.")
    unsafe_growlast!(order(v), v, i)
    return v
end

function unsafe_growlast!(vo::ForwardOrdering, v::AbstractVector{T}, i::Integer) where {T}
    li = lastindex(v) + 1
    lastval = last(v)
    append!(v, Vector{T}(undef, i))
    for idx in li:lastindex(v)
        lastval = nexttype(lastval)
        v[idx] = lastval
    end
end

function unsafe_growlast!(vo::ReverseOrdering, v::AbstractVector{T}, i::Integer) where {T}
    li = lastindex(v) + 1
    lastval = last(v)
    append!(v, Vector{T}(undef, i))
    for idx in li:lastindex(v)
        lastval = prevtype(lastval)
        v[idx] = lastval
    end
end

function growlast!(r::AbstractUnitRange, i)
    can_setlast(r) || error("Type $(typeof(r)) cannot grow.")
    unsafe_growlast!(r, i)
    return r
end
function unsafe_growlast!(a::AbstractRange{T}, i) where {T}
    return setlast!(a, last(a) + step(a) * T(i))
end

"""
    growfirst!(v, n) -> v

Grow the collection `v` from the first position by `n` elements.
"""
function growfirst!(v, n)
    isgrowable(v) || error("Type $(typeof(v)) cannot grow.")
    _growfirst!(order(v), v, n)
    return v
end

function _growfirst!(::ReverseOrdering, v::AbstractVector, n)
    for i in 1:n
        pushfirst!(v, nexttype(first(v)))
    end
end

function _growfirst!(::ForwardOrdering, v::AbstractVector, n)
    for i in 1:n
        pushfirst!(v, prevtype(first(v)))
    end
    return v
end

_growfirst(r::AbstractRange{T}, i) where {T} = setfirst!(r, first(r) - (T(i) * step(r)))

_growfirst!(r::AbstractUnitRange{T}, i) where {T} = setfirst!(r, first(r) - T(i))

"""
    growlast(v, i)
"""
growlast(v, i) = can_growlast(v) ? growlast!(copy(a), i) : _growlast(order, v, i)
function _growlast(a::AbstractUnitRange{T}, i::Integer) where {T}
    return UnitRange(first(a), T(last(a) + i))
end

function _growlast(a::OrdinalRange{T}, i) where {T}
    return similar_type(a)(first(a), step(a), last(a) + step(a) * T(i))
end
function _growlast(a::AbstractUnitRange{T}, i) where {T}
    return similar_type(a)(first(a), step(a), last(a) + T(i))
end

# TODO: would be nice if this returned the same type as `a`
_growlast(a::AbstractVector, i::Integer) where {T} = growlast!(Vector(a), i)

"""
    growfirst(a, i)
"""
growfirst(a, i) = can_growfirst(a) ? growfirst!(copy(a), i) : _growfirst(a, i)
function _growfirst(a::AbstractUnitRange{T}, i::Integer) where {T}
    UnitRange(T(first(a) - i), last(a))
end
function _growfirst(a::AbstractRange, i::Integer)
    if sign(step(a)) == 1
        return (first(a) - step(a) * i):step(a):last(a)
    else
        return (first(a) + step(a) * i):step(a):last(a)
    end
end
_growfirst(a::AbstractVector{T}, i::Integer) where {T} = append!(rand(T, i), a)
_growfirst(a::AbstractVector{Symbol}, i::Integer) = append!(Symbol.(rand(Char, i)), a)
function _growfirst(a::AbstractVector{<:AbstractString}, i::Integer)
    append!(String.(Symbol.(rand(Char, i))), a)
end
