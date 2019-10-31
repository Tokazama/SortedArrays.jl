# ensure that when setting an index preserves order
function check_setindex(::ForwardOrdering, sv, val, i::Integer) where {T,P}
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

function check_setindex(::ReverseOrdering, sv, val, i::Integer)
    @inbounds if i > firstindex(sv)
        if i < lastindex(sv)
            return getindex(x, i-1) > val > getindex(sv, i+1)
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

#=
function Base.setindex!(sv::SortedVector, val, inds::AbstractVector)
    if findorder(inds) isa UnorderedOrdering
        # make sure that every index is boundschecked since we don't know order
        for i in inds
            setindex!(sv, val, i)
        end
    else
        @boundscheck check_setindex(order(sv), parent(sv), val, inds)
        @inbounds setindex!(parent(sv), val, inds)
    end
end
=#
###
### setindex!
###

@propagate_inbounds function Base.setindex!(sv::SortedVector, val, i)
    @boundscheck check_setindex(order(sv), parent(sv), val, i)
    @inbounds setindex!(parent(sv), val, i)
end

@propagate_inbounds function Base.setindex!(sv::SortedVector, val, inds::AbstractVector)
    if order(inds) isa UnorderedOrdering
        # make sure that every index is boundschecked since we don't know order
        for i in inds
            setindex!(sv, val, i)
        end
    else
        @boundscheck check_setindex(order(sv), parent(sv), val, inds)
        @inbounds setindex!(parent(sv), val, inds)
    end
end
