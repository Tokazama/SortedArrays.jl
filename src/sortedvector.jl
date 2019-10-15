struct SortedVector{T,P<:AbstractVector{T},O} <: AbstractVector{T}
    _parent::P

    function SortedVector{T,P,O}(p::P, ::IsSortedTrait{false}) where {T,P,O}
        issorted(p, order=O) || error("Order is specified as $O but provided container is not that order.")
        new{T,P,O}(p)
    end

    # skip sorting if we checked in previous method
    function SortedVector{T,P,O}(p::P, ::IsSortedTrait{true}) where {T,P,O}
        new{T,P,O}(p)
    end
end

SortedVector(sv::SortedVector) = sv

function SortedVector(vec_ord::Tuple{AbstractVector,Ordering})
    return SortedVector(first(vec_ord), last(vec_ord), IsSorted)
end

SortedVector(v::AbstractVector) = SortedVector(v, findorder(v), IsSorted)
function SortedVector(v::AbstractVector, o::Ordering, sorted_state::IsSortedTrait=NotSorted)
    return SortedVector{eltype(v),typeof(v),o}(v, sorted_state)
end

Base.parent(sv::SortedVector) = getfield(sv, :_parent)
order(::Type{SortedVector{T,P,O}}) where {T,P,O} = O

isforward(::SortedVector{T,P,Forward}) where {T,P} = true
isforward(::SortedVector{T,P,O}) where {T,P,O} = false

isreverse(::SortedVector{T,P,Reverse}) where {T,P} = true
isreverse(::SortedVector{T,P,O}) where {T,P,O} = false

function Base.pop!(sv::SortedVector)
    pop!(parent(sv))
    return sv
end

function Base.popfirst!(sv::SortedVector)
    popfirst!(parent(sv))
    return sv
end

function Base.push!(sv::SortedVector, items...)
    push!(parent(sv), items...)
    return sv
end

function Base.pushfirst!(sv::SortedVector, items...)
    pushfirst!(parent(sv), items...)
    return sv
end

###
### setindex!
###

# ensure that when setting an index it's not out of order
function check_setindex(sv::SortedVector{T,P,Forward}, val, i::Integer) where {T,P}
    @inbounds if i > firstindex(sv)
        if i < lastindex(sv)
            return getindex(sv, i-1) < val < getindex(sv, i+1)
        elseif i == lastindex(sv)
            return getindex(sv, i-1) < val
        else
            return false
        end
    elseif i == firstindex(sv)
        if i < lastindex(sv)
            return val < getindex(sv, i+1)
        elseif i == lastindex(sv)
            return true  # at this point `vs` can only have 1 element (must be in order)
        else
            return false
        end
    else
        return false
    end
end

function check_setindex(sv::SortedVector{T,P,Reverse}, val, i::Integer) where {T,P}
    @inbounds if i > firstindex(sv)
        if i < lastindex(sv)
            return getindex(sv, i-1) > val > getindex(sv, i+1)
        elseif i == lastindex(sv)
            return getindex(sv, i-1) > val
        else
            return false
        end
    elseif i == firstindex(sv)
        if i < lastindex(sv)
            return val > getindex(sv, i+1)
        elseif i == lastindex(sv)
            return true
        else
            return false
        end
    else
        return false
    end
end


@propagate_inbounds function Base.setindex!(sv::SortedVector, val, i)
    @boundscheck check_setindex(sv, val, i)
    @inbounds setindex!(parent(sv), val, i)
end

@propagate_inbounds function Base.setindex!(sv::SortedVector, val, inds::AbstractVector)
    if order(inds) isa UnorderedOrdering
        # make sure that every index is boundschecked since we don't know order
        for i in inds
            setindex!(sv, val, i)
        end
    else
        @boundscheck check_setindex(sv, val, inds)
        @inbounds setindex!(parent(sv), val, inds)
    end
end

