
abstract type SortedTrait end

"IsOrderedTrait"
struct IsOrderedTrait <: SortedTrait end
const IsOrdered = IsOrderedTrait()

struct NotOrderedTrait <: SortedTrait end
const NotOrdered = NotOrderedTrait()

"IsUniqueElementsTrait - Indicates that all of a collection's elements are unique."
struct IsUniqueElementsTrait end
const IsUniqueElements = IsUniqueElementsTrait()

"NotUniqueElementsTrait - Indicates that all not all of a collection's elements are unique."
struct NotUniqueElementsTrait end
const NotUniqueElements = NotUniqueElementsTrait()

"UnorderedOrdering - Indicates that a collection's is not forward or reverse ordered."
struct UnorderedOrdering <: Ordering end
const Unordered = UnorderedOrdering()

"UnkownOrdering - Indicates that a collection's ordering is not known."
struct UnkownOrdering <: Ordering end
const UnkownOrder = UnkownOrdering()

const RFOrder = Union{ForwardOrdering,ReverseOrdering}
const UUOrder = Union{UnkownOrdering,UnkownOrdering}

# TODO reverse would make more sense here but that would be type piracy
opposite(::ForwardOrdering) = Reverse
opposite(::ReverseOrdering) = Forward
opposite(::typeof(<)) = (>)
opposite(::typeof(>)) = (<)
opposite(::typeof(==)) = (==)
opposite(::typeof(<=)) = (>=)
opposite(::typeof(>=)) = (<=)

maybe_flip(xo::O, yo::O, inds) where {O<:Ordering} = inds
maybe_flip(xo::Ordering, yo::Ordering, inds) = reverse(inds)

"""
    order(x) -> Ordering

Returns the ordering of `x`.
"""
order(x::T) where {T} = _order(order(T), x)
function _order(::UnkownOrdering, x)
    if isreverse(x)
        return Reverse
    elseif isforward(x)
        return Forward
    else
        return Unordered
    end
end
_order(xo::Ordering, x) = xo
order(::Type{T}) where {T} = UnkownOrder
order(::Type{T}) where {T<:AbstractUnitRange} = Forward

"""
    isforward(x) -> Bool

Returns `true` if `x` is sorted forward.
"""
isforward(x) = issorted(x)
isforward(::ForwardOrdering) = true
isforward(::Ordering) = false
isforward(::AbstractUnitRange) = true
isforward(x::AbstractRange) = step(x) > 0

"""
    isreverse(x) -> Bool

Returns `true` if `x` is sorted in reverse.
"""
isreverse(x) = issorted(x, order=Reverse)
isreverse(::ReverseOrdering) = true
isforwardsreverse(::Ordering) = false
isreverse(::AbstractUnitRange) = false
isreverse(x::AbstractRange) = step(x) < 0

"""
    isordered(x) -> Bool

Returns `true` if `x` is ordered. `isordered` should return the same value that
`issorted` would on `x` except it doesn't specify how it's sorted (e.g.,
forward, revers, etc).
"""
isordered(::AbstractRange) = true
isordered(x) = isforward(x) || isreverse(x)

"""
    ordmax(x) = ordmax(order(x), x)
    ordmax(::Ordering, x::T) -> T

Finds the maximum of `x` using information about its ordering.
"""
ordmax(x) = ordmax(order(x), x)
ordmax(::ForwardOrdering, x) = last(x)
ordmax(::ReverseOrdering, x) = first(x)
ordmax(::UnkownOrdering, x) = maximum(x)
ordmax(::UnorderedOrdering, x) = maximum(x)

"""
    ordmin(x) = ordmin(order(x), x)
    ordmin(::Ordering, x::T) -> T

Finds the minimum of `x` using information about its ordering.
"""
ordmin(x) = ordmin(order(x), x)
ordmin(::ForwardOrdering, x) = first(x)
ordmin(::ReverseOrdering, x) = last(x)
ordmin(::UnkownOrdering, x) = minimum(x)
ordmin(::UnorderedOrdering, x) = minimum(x)

"""
    ordfindmax
"""
ordfindmax(v) = ordfindmax(order(v), v)
ordfindmax(::ForwardOrdering, v::AbstractVector) = lastindex(v)
ordfindmax(::ReverseOrdering, v::AbstractVector) = firstindex(v)
function ordfindmax(::UUOrder, v::AbstractRange)
    first(v) < last(v) ? lastindex(v) : firstindex(v)
end
ordfindmax(::UUOrder, v::AbstractVector) = findmax(v)

"""
    ordfindmin
"""
ordfindmin(v) = ordfindmin(order(v), v)
ordfindmin(::ForwardOrdering, v::AbstractVector) = firstindex(v)
ordfindmin(::ReverseOrdering, v::AbstractVector) = lastindex(v)
function ordfindmin(::UUOrder, v::AbstractRange)
    first(v) < last(v) ? firstindex(v) : lastindex(v)
end
ordfindmin(::UUOrder, v::AbstractVector) = findmin(v)

"""
    iswithin(x, y) -> Bool

Returns `true` if all of `x` is found within `y`. Does not return `true` if the
smallest minimum of `x` and `y` are equal or if the maximum of `x` and `y` are
equal.
"""
#= TODO delete this garbage once the rest of iswithin is validated
iswithin(x::AbstractVector, y) = iswithin(order(x), order(y), x, y)
iswithin(::ForwardOrdering, ::ForwardOrdering, x, y) = (first(x)   > first(y)  ) & (last(x)    < last(y))
iswithin(::ForwardOrdering, ::ReverseOrdering, x, y) = (first(x)   > last(y)   ) & (last(x)    < first(y))
iswithin(::ReverseOrdering, ::ForwardOrdering, x, y) = (last(x)    > first(y)  ) & (first(x)   < last(y))
iswithin(::ReverseOrdering, ::ReverseOrdering, x, y) = (last(x)    > last(y)   ) & (first(x)   < first(y))
iswithin(::ForwardOrdering, ::UUOrder,         x, y) = (last(x)    < maximum(y)) & (first(x)   > minimum(y))
iswithin(::ReverseOrdering, ::UUOrder,         x, y) = (first(x)   < maximum(y)) & (last(x)    > minimum(y))
iswithin(::UUOrder,         ::ForwardOrdering, x, y) = (minimum(x) > first(y)  ) & (maximum(x) < last(y))
iswithin(::UUOrder,         ::ReverseOrdering, x, y) = (minimum(x) > last(y)   ) & (maximum(x) < first(y))
iswithin(::UUOrder,         ::UUOrder,         x, y) = (minimum(x) > minimum(y)) & (maximum(x) < maximum(y))
=#

iswithin(x, y) = iswithin(order(x), order(y), x, y)

function iswithin(xo, yo::ReverseOrdering, x, y)
    return (last(y) > ordmin(xo, x) || ordmax(xo, x) > first(y)) ? false : true
end
function iswithin(xo, yo::ForwardOrdering, x, y)
    return (first(y) > ordmin(xo, x) || ordmax(xo, x) > last(y)) ? false : true
end
iswithin(y) = Fix2(iswithin, y)

"""
    isbefore(x::T, y::T, collection::AbstractVector{T}) -> Bool

Returns `true` if `x` is before `y` in `collection`.
"""
function isbefore(x, y, collection)
    findfirst(isequal(x), collection) < findfirst(isequal(y), collection)
end



"""
    isbefore(x::AbstractVector{T}, y::AbstractVector{T}) -> isbefore(order(x), order(y), x, y)
    isbefore(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if all elements in `x` are before all elements in `y`. Functionally
equivalent to `all(x .< y)`.
"""
isbefore(x, y) = isbefore(order(x), order(y), x, y)
isbefore(xo, yo, x, y) = ordmax(xo, x) < ordmin(yo, y)

"""
    ispartbefore(x, y) -> Bool

Returns `true` if part of the values of `x` is before `y`.
"""
ispartbefore(x, y) = ispartbefore(order(x), order(y), x, y)
ispartbefore(xo, yo, x, y) = ordmin(xo, x) < ordmin(yo, y) < ordmax(xo, x)

"""
    isafter(x::T, y::T, collection::AbstractVector{T}) -> Bool

Returns `true` if `x` is after `y` in `collection`.
"""
function isafter(x, y, collection)
    findfirst(isequal(x), collection) > findfirst(isequal(y), collection)
end

"""
    isafter(x::AbstractVector{T}, y::AbstractVector{T}) -> isafter(order(x), order(y), x, y)
    isafter(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if all elements in `x` are after all elements in `y`. Functionally
equivalent to `all(x .> y)`.
"""
isafter(x, y) = isafter(order(x), order(y), x, y)
isafter(xo, yo, x, y) = ordmin(x) > ordmax(y)

"""
    ispartafter(x, y) -> Bool

Returns `true` if part of the values of `x` is after `y`.
"""
ispartafter(x, y) = ispartafter(order(x), order(y), x, y)
ispartafter(xo, yo, x, y) = ordmax(xo, x) > ordmax(yo, y) > ordmin(xo, x)

"""
    iscontiguous(x, y) = iscontiguous(order(x), order(y), x, y)
    iscontiguous(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if one of the ends of `x` may be extended by a single overlapping
end of `y`.

# Example
```
julia> iscontiguous(1:3, 3:4) == true

julia> iscontiguous(3:-1:1, 3:4) == true

julia> iscontiguous(3:-1:1, 4:-1:3) == true

julia> iscontiguous(1:3, 4:-1:3) == true

julia> iscontiguous(1:3, 2:4) == false
```
"""
iscontiguous(x, y) = iscontiguous(order(x), order(y), x, y)
function iscontiguous(::ForwardOrdering, yo, x, y)
    return last(x) == ordmin(yo, y) || first(x) == ordmax(yo, y)
end
function iscontiguous(::ReverseOrdering, yo, x, y)
    return last(x) == ordmax(yo, y) || first(x) == ordmin(yo, y)
end

"""
    gtmax(x, y) -> Bool

Returns `true` if the maximum of `x` is greater than that of `y`.
"""
gtmax(x, y) = gtmax(order(x), order(y), x, y)
gtmax(xo, yo, x, y) = ordmax(xo, x) > ordmax(yo, y)

"""
    ltmax(x, y) -> Bool

Returns `true` if the maximum of `x` is less than that of `y`.
"""
ltmax(x, y) = ltmax(order(x), order(y), x, y)
ltmax(xo, yo, x, y) = ordmax(xo, x) < ordmax(yo, y)

"""
    eqmax(x, y) -> Bool

Returns `true` if the maximum of `x` and `y` are equal.
"""
eqmax(x, y) = eqmax(order(x), order(y), x, y)
eqmax(xo, yo, x, y) = ordmax(xo, x) == ordmax(yo, y)


"""
    gtmin(x, y) -> Bool

Returns `true` if the minimum of `x` is greater than that of `y`.
"""
gtmin(x, y) = gtmin(order(x), order(y), x, y)
gtmin(xo, yo, x, y) = ordmin(xo, x) > ordmin(yo, y)

"""
    ltmin(x, y) -> Bool

Returns `true` if the minimum of `x` is less than that of `y`.
"""
ltmin(x, y) = ltmax(order(x), order(y), x, y)
ltmin(xo, yo, x, y) = ordmin(xo, x) < ordmin(yo, y)

"""
    eqmin(x, y) -> Bool

Returns `true` if the minimum of `x` and `y` are equal.
"""
eqmin(x, y) = eqmin(order(x), order(y), x, y)
eqmin(xo, yo, x, y) = ordmin(xo, x) == ordmin(yo, y)

"""
    groupmax(x, y[, z...])

Returns the maximum value of all collctions.
"""
groupmax(x, y, z...) = max(groupmax(x, y), groupmax(z...))
groupmax(x) = ordmax(x)
groupmax(x, y) = _groupmax(order(x), order(y), x, y)
_groupmax(xo, yo, x, y) = max(ordmax(xo, x), ordmax(yo, y))

"""
    groupmin(x, y[, z...])

Returns the minimum value of all collctions.
"""
groupmin(x, y, z...) = min(groupmin(x, y), groupmin(z...))
groupmin(x) = ordmin(x)
groupmin(x, y) = _groupmin(order(x), order(y), x, y)
_groupmin(xo, yo, x, y) = min(ordmin(xo, x), ordmin(yo, y))


cmpmax(xo, yo, x, y) = ltmax(xo, yo, x, y) ? -1 : (gtmax(xo, yo, x, y) ? 1 : 0)
cmpmin(xo, yo, x, y) = ltmin(xo, yo, x, y) ? -1 : (gtmin(xo, yo, x, y) ? 1 : 0)

"""
    min_of_groupmax(x, y)

Returns the minimum of maximum of `x` and `y`. Functionally equivalent to
`min(maximum(x), maximum(y))` but uses trait information about ordering for
improved performance.
"""
min_of_groupmax(x, y) = min_of_groupmax(order(x), order(y), x, y)
min_of_groupmax(xo, yo, x, y) = min(ordmax(xo, x), ordmax(xo, x))

"""
    max_of_groupmin(x, y)

Returns the maximum of minimum of `x` and `y`. Functionally equivalent to
`max(minimum(x), minimum(y))` but uses trait information about ordering for
improved performance.
"""
max_of_groupmin(x, y) = max_of_groupmin(order(x), order(y), x, y)
max_of_groupmin(xo, yo, x, y) = max(ordmin(xo, x), ordmin(xo, x))

"""
    nexttype(x::T)

Returns the immediately greater value of type `T`.
"""
function nexttype(x::AbstractString)
    isempty(x) && return ""
    return x[1:prevind(x, lastindex(x))] * (last(x) + 1)
end
nexttype(x::Symbol) = Symbol(nexttype(string(x)))
nexttype(x::AbstractChar) = x + 1
nexttype(x::T) where {T<:AbstractFloat} = nextfloat(x)
nexttype(x::T) where {T} = x + one(T)

"""
    prevtype(x::T)

Returns the immediately lesser value of type `T`.
"""
function prevtype(x::AbstractString)
    isempty(x) && return ""
    return x[1:prevind(x, lastindex(x))] * (last(x) - 1)
end
prevtype(x::Symbol) = Symbol(prevtype(string(x)))
prevtype(x::AbstractChar) = x - 1
prevtype(x::T) where {T<:AbstractFloat} = prevfloat(x)
prevtype(x::T) where {T} = x - one(T)

