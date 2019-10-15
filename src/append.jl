
"""
    sorted_append!(x, y) -> (x, ::Order)
"""
sorted_append!(x, y) = sorted_append!(order(x), order(y), x, y)
function sorted_append!(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return unsafe_stack!(xo, yo, x, y), xo
    else
        return append!(x, y), Unordered
    end
end

# mutable stack
unsafe_stack(::ForwardOrdering, ::ForwardOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == first(y)) ? _stack_range(xo, yo, x, y) : vcat(x, y)

unsafe_stack(::ForwardOrdering, ::ReverseOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == last(y)) ? _stack_range(xo, yo, x, y) : vcat(x, y)

unsafe_stack(xo::ReverseOrdering, yo::ForwardOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == last(y)) ? _stack_range(xo, yo, x, y) : vcat(x, reverse(y))

unsafe_stack(::ReverseOrdering, ::ReverseOrdering, x::AbstractRange, y::AbstractRange) =
    step(x) == step(y) && (last(x) + step(x) == first(y)) ? _stack_range(xo, yo, x, y) : vcat(x, y)

_stack_range(xo, yo, x::AbstractUnitRange, y) = typeof(x)(first(x), last(y))

_stack_range(xo, yo, x::OrdinalRange, y) = typeof(x)(first(x), step(x), last(y))

_stack_range(xo, yo, x::AbstractRange, y) = first(x):step(x):last(y)

_stack_range!(::ForwardOrdering, yo, x::MRange, y) = (setlast!(x, last(y)): x)

