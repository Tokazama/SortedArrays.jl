function unsafe_mergesort!(xindex, yindex, xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    y_i, state = iterate(yindex)
    @inbounds for x_i in xindex
        while y[y_i] < x[x_i]
            insert!(x, x_i, y[y_i])
            isnothing(state) && return x
            y_i, state = iterate(yindex, state)
        end
    end
    return x
end

function unsafe_mergesort!(xindex, yindex, xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    return unsafe_mergesort!(xindex, reverse(yindex), Forward, Forward, x, y)
end

function unsafe_mergesort!(xindex, yindex, xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    y_i, state = iterate(yindex)
    @inbounds for x_i in xindex
        while y[y_i] > x[x_i]
            insert!(x, x_i, y[y_i])
            isnothing(state) && return x
            y_i, state = iterate(yindex, state)
        end
    end
    return x
end
function unsafe_mergesort!(xindex, yindex, xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    return unsafe_mergesort!(xindex, reverse(yindex), Forward, Forward, x, y)
end

function unsafe_mergesort!(xindex, yindex, xo::ForwardOrdering, yo::UUOrder, x, y)
    @inbounds for y_i in yindex
        if y[y_i] > last(x)
            push!(x, y[y_i])
        else
            for x_i in xindex
                if y[y_i] < x[x_i]
                    insert!(x, x_i, y[y_i])
                else
                    break
                end
            end
        end
    end
    return x
end

function unsafe_mergesort!(xindex, yindex, xo::ReverseOrdering, yo::UUOrder, x, y)
    @inbounds for y_i in yindex
        if y[y_i] < last(x)
            push!(x, y[y_i])
        else
            for x_i in xindex
                if y[y_i] > x[x_i]
                    insert!(x, x_i, y[y_i])
                else
                    break
                end
            end
        end
    end
    return x
end


# FIXME I'm sure there's a more efficient way to handle these
function unsafe_mergesort!(xindex, yindex, xo::UUOrder, yo::ReverseOrdering, x, y)
    x[xindex] = x[xindex[sortperm(x[xindex], order=Reverse)]]
    return unsafe_mergesort!(xindex, yindex, Reverse, Reverse, x, y)
end

function unsafe_mergesort!(xindex, yindex, xo::UUOrder, yo::ForwardOrdering, x, y)
    x[xindex] = x[xindex[sortperm(x[xindex], order=Forward)]]
    return unsafe_mergesort!(xindex, yindex, Forward, Forward, x, y)
end

function unsafe_mergesort!(xindex, yindex, xo::UUOrder, yo::UUOrder, x, y)
    y[yindex] = y[yindex[sortperm(y[yindex], order=Forward)]]
    x[xindex] = x[xindex[sortperm(x[xindex], order=Forward)]]
    return unsafe_mergesort!(xindex, yindex, Forward, Forward, x, y)
end

###
### unsafe_mergesort
###
function unsafe_mergesort() end