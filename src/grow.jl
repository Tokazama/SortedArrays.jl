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

"""
    can_growfirst(x) -> Bool

A trait function for whether `x` can grow from its first position. If `x` is a
range this means that the method `set_first!` is available for us on `x`.
"""
can_growfirst(::X) where {X} = can_growfirst(X)
can_growfirst(::Type{X}) where {X} = isgrowable(X)

"""
    can_growlast(x) -> Bool

A trait function for whether `x` can grow from its last position. If `x` is a
range this means that the method `set_last!` is available for us on `x`.
"""
can_growlast(::X) where {X} = can_growlast(X)
can_growlast(::Type{X}) where {X} = isgrowable(X)

"""
    growlast!(a, i) -> a

Requires that `a` is a subtype of `AbstractRange` or is a vector containing
random generatable eltypes.
"""
function growlast!(a::AbstractUnitRange{T}, i::Integer) where {T}
    isgrowable(a) || error("Type $(typeof(a)) cannot grow.")
    setlast!(a, last(a) + T(i))
    return a
end

function growlast!(a::AbstractRange{T}, i::Integer) where {T}
    isgrowable(a) || error("Type $typeof(a) cannot grow.")
    setlast!(a, last(a) + step(a) * T(i))
    return a
end

function growlast!(a::A, i) where {A}
    isgrowable(A) || error("Type $A cannot grow.")
    _growlast(order(a), a, i)
    return a
end

function _growlast!(vo::ForwardOrdering, v::AbstractVector{T}, i::Integer) where {T}
    li = lastindex(v) + 1
    lastval = last(v) 
    append!(v, Vector{T}(undef, i))
    for idx in li:lastindex(v)
        lastval = nexttype(lastval)
        v[idx] = lastval
    end
end

function _growlast!(vo::ReverseOrdering, v::AbstractVector{T}, i::Integer) where {T}
    li = lastindex(v) + 1
    lastval = last(v)
    append!(v, Vector{T}(undef, i))
    for idx in li:lastindex(v)
        lastval = prevtype(lastval)
        v[idx] = lastval
    end
end

"""
    growfirst!(a, n) -> a

Grow the collection `a` from the first position by `n` elements.
"""
function growfirst!(a, n)
    can_growfirst(a) || error("Type $(typeof(a)) cannot grow.")
    _growfirst!(order(a), a, n)
    return a
end

function _growfirst(a::AbstractRange{T}, i) where {T}
    setfirst!(a, first(a) - (T(i) * step(a)))
    return nothing
end

function _growfirst!(a::AbstractUnitRange{T}, i) where {T}
    setfirst!(a, first(a) - T(i))
    return nothing
end


function _growfirst!(::ReverseOrdering, a::AbstractVector{T}, n) where {T}
    for i in 1:n
        pushfirst!(a, nexttype(first(a)))
    end
end

function _growfirst!(::ForwardOrdering, a::AbstractVector{T}, n) where {T}
    for i in 1:n
        pushfirst!(a, prevtype(first(a)))
    end
end


"""
    growlast(a, i)
"""
function growlast(a, i)
    if can_growlast(a)
        return growlast!(copy(a), i)
    else
        return _growlast(a, i)
    end
end
function _growlast(a::AbstractUnitRange{T}, i::Integer) where {T}
    return UnitRange(first(a), T(last(a) + i))
end
function _growlast(a::AbstractRange, i::Integer)
    if sign(step(a)) == 1
        return first(a):step(a):(last(a) + step(a) * i)
    else
        return first(a):step(a):(last(a) - step(a) * i)
    end
end
# TODO: would be nice if this returned the same time as `a`
_growlast(a::AbstractVector, i::Integer) where {T} = growlast!(Vector(a), i)

"""
    growfirst(a, i)
"""
function growfirst(a, i)
    if can_growfirst(a)
        return growfirst!(copy(a), i)
    else
        return _growfirst(a, i)
    end
end
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
