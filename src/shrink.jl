"""
    shrinklast!(x, i) -> x

Returns a colletion of `x` with the last `i` elements of `x` removed. This
method is non mutating.
"""
function shrinklast!(a::AbstractUnitRange, i::Integer)
    setlast!(a, first(a) + i)
    return a
end
function shrinklast!(a::AbstractRange, i::Integer)
    if isforward(a)
        setlast!(a, first(a) + step(a) * i)
    else
        setlast!(a, first(a) - step(a) * i)
    end
    return a
end
function shrinklast!(a::AbstractVector, i::Integer)
    for n in 1:i
        pop!(a)
    end
    return a
end

"""
    shrinkfirst!(x, i)

Returns a colletion of `x` with the one through `i` elements of `x` removed.
This method is non mutating.
"""
function shrinkfirst!(a::AbstractUnitRange, i::Integer)
    setfirst!(a, first(a) + i)
    return a
end
function shrinkfirst!(a::AbstractRange, i::Integer)
    if isforward(a)
        setfirst!(a, first(a) + step(a) * i)
    else
        setfirst!(a, first(a) - step(a) * i)
    end
    return a
end
function shrinkfirst!(a::AbstractVector, i::Integer)
    for n in 1:i
        popfirst!(a)
    end
    return a
end

"""
    shrinklast(x, i) -> x

Returns a colletion of `x` with the last `i` elements of `x` removed. This
method is non mutating.
"""
function shrinklast(x, i)
    # we assume if it can crow at the last position it can also shrink there
    can_growlast(x) ? shrinklast!(copy(x), i) : _shrinklast(x, i)
end
_shrinklast(a, i::Integer) = a[1:end - i]
_shrinklast(a::Tuple, i::Integer) = Tuple([a[n] for n in 1:length(a) - i])


"""
    shrinkfirst(x, i) -> x

Returns a colletion of `x` with the last `i` elements of `x` removed. This
method is non mutating.
"""
function shrinkfirst(x, i)
    # we assume if it can crow at the last position it can also shrink there
    can_growfirst(x) ? shrinkfirst!(copy(x), i) : _shrinkfirst(x, i)
end
_shrinklfirst(a, i::Integer) = a[(firstindex(a)+i):end]
_shrinkfirst(a::Tuple, i::Integer) = Tuple([a[n] for n in (1 + i):length(a)])
