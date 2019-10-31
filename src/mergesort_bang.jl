###
### unsafe_mergesort!
###
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

###
### _mergesort!
###

# x seg - overlap - x seg
_mergesort!(::typeof(<), ::typeof(>), xo::ForwardOrdering, yo::ForwardOrdering, x, y) =
    unsafe_mergesort!(nearbefore(first(y), xo, x):nearafter(last(y), xo, x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(<), ::typeof(>), xo::ForwardOrdering, yo::ReverseOrdering, x, y) =
    unsafe_mergesort!(nearbefore(last(y), xo, x):nearafter(first(y), xo, x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(>), ::typeof(<), xo::ReverseOrdering, yo::ForwardOrdering, x, y) =
    unsafe_mergesort!(nearbefore(last(y), xo, x):nearafter(first(y), xo, x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(>), ::typeof(<), xo::ReverseOrdering, yo::ReverseOrdering, x, y) =
    unsafe_mergesort!(nearbefore(first(y), xo, x):nearafter(last(y), xo, x), eachindex(y), xo, yo, x, y)

# y seg - overlap - y seg
function _mergesort!(::typeof(>), ::typeof(<), xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(eachindex(x), near(first(x), yo, y):near(last(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, nearafter(last(x), yo, y):lastindex(y)))
    unsafe_prependsort!(xo, yo, x, view(y, firstindex(y):nearbefore(first(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(<), xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(eachindex(x), near(last(x), yo, y):near(first(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, firstindex(y):nearbefore(last(x), yo, y)))
    unsafe_prependsort!(xo, yo, x, view(y, nearafter(first(x), yo, y):lastindex(y)))
    return x
end
function _mergesort!(::typeof(<), ::typeof(>), xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(eachindex(x), near(first(x), yo, y):near(last(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, firstindex(y):nearbefore(last(x), yo, y)))
    unsafe_prependsort!(xo, yo, x, view(y, firstindex(y):nearbefore(first(x), yo, y)))
    return x
end
function _mergesort!(::typeof(<), ::typeof(>), xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(eachindex(x), near(last(x), yo, y):near(first(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, nearafter(last(x), yo, y):lastindex(y)))
    unsafe_prependsort!(xo, yo, x, view(y, nearafter(first(x), yo, y):lastindex(y)))
    return x
end

# x seg - overlap - y seg
function _mergesort!(::typeof(<), ::typeof(<), xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(near(first(y), xo, x):lastindex(x), firstindex(y):near(last(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, nearafter(last(x), yo, y):lastindex(y)))
    return x
end
function _mergesort!(::typeof(<), ::typeof(<), xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(near(last(y), xo, x):lastindex(x), near(last(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, firstindex(y):nearbefore(last(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(>), xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(near(last(y), xo, x):lastindex(x), near(last(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, firstindex(y):nearbefore(last(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(>), xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(near(first(y), xo, x):lastindex(x), firstindex(y):near(last(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(xo, yo, x, view(y, nearafter(last(x), yo, y):lastindex(y)))
    return x
end

# y seg - overlap - x seg
function _mergesort!(::typeof(>), ::typeof(>), xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(firstindex(x):near(last(y), xo, x), near(first(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_prependsort!(xo, yo, x, view(y, firstindex(y):nearbefore(first(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(>), xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(firstindex(x):near(first(y), xo, x), firstindex(y):near(first(x), yo, y), xo, yo, x, y)
    unsafe_prependsort!(xo, yo, x, view(y, nearafter(first(x), yo, y):lastindex(y)))
    return x
end
function _mergesort!(::typeof(<), ::typeof(<), xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(firstindex(x):near(last(y), xo, x), near(first(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_prependsort!(xo, yo, x, view(y, firstindex(y):nearbefore(first(x), yo, y)))
    return x
end
function _mergesort!(::typeof(<), ::typeof(<), xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(firstindex(x):near(first(y), xo, x), firstindex(y):near(first(x), yo, y), xo, yo, x, y)
    unsafe_prependsort!(xo, yo, x, view(y, nearafter(first(x), yo, y):lastindex(y)))
    return x
end

# x seg - overlap
_mergesort!(::typeof(<), ::typeof(==), xo::ForwardOrdering, yo::ForwardOrdering, x, y) =
    unsafe_mergesort!(nearafter(ordmin(yo, y), xo, x):lastindex(x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(<), ::typeof(==), xo::ForwardOrdering, yo::ReverseOrdering, x, y) =
    unsafe_mergesort!(nearafter(ordmin(yo, y), xo, x):lastindex(x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(==), ::typeof(>), xo::ReverseOrdering, yo::ReverseOrdering, yo, x, y) =
    unsafe_mergesort!(nearafter(ordmax(yo, y), xo, x):lastindex(x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(==), ::typeof(>), xo::ReverseOrdering, yo::ForwardOrdering, yo, x, y) =
    unsafe_mergesort!(nearafter(ordmax(yo, y), xo, x):lastindex(x), eachindex(y), xo, yo, x, y)

# y seg - overlap
function _mergesort!(::typeof(>), ::typeof(==), xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(eachindex(x), nearafter(first(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_prependsort!(x, view(y, firstindex(y):near(first(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(==), xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(eachindex(x), firstindex(y):nearbefore(first(x), yo, y), xo, yo, x, y)
    unsafe_prependsort!(x, view(y, near(first(x), yo, y):lastindex(y)))
    return x
end
function _mergesort!(::typeof(==), ::typeof(<), xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(eachindex(x), firstindex(y):nearbefore(first(x), yo, y), xo, yo, x, y)
    unsafe_prependsort!(x, view(y, near(first(x), yo, y):lastindex(y)))
    return x
end
function _mergesort!(::typeof(==), ::typeof(<), xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(eachindex(x), firstindex(y):nearbefore(first(x), yo, y), xo, yo, x, y)
    unsafe_prependsort!(x, view(y, near(first(x), yo, y):lastindex(y)))
    return x
end

# overlap - x seg
_mergesort!(::typeof(==), ::typeof(>), xo::ForwardOrdering, yo::ForwardOrdering, x, y) =
    unsafe_mergesort!(firstindex(x):nearbefore(ordmax(yo, y), xo, x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(==), ::typeof(>), xo::ForwardOrdering, yo::ReverseOrdering, x, y) =
    unsafe_mergesort!(firstindex(x):nearbefore(ordmax(yo, y), xo, x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(<), ::typeof(==), xo::ReverseOrdering, yo::ReverseOrdering, x, y) =
    unsafe_mergesort!(firstindex(x):nearbefor(ordmin(yo, y), xo, x), eachindex(y), xo, yo, x, y)
_mergesort!(::typeof(<), ::typeof(==), xo::ReverseOrdering, yo::ForwardOrdering, x, y) =
    unsafe_mergesort!(firstindex(x):nearbefor(ordmin(yo, y), xo, x), eachindex(y), xo, yo, x, y)

# overlap - y seg
function _mergesort!(::typeof(==), ::typeof(<), xo::ForwardOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(eachindex(x), nearbefore(last(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_appendsort!(Forward, Forward, x, view(y, firstindex(x):near(last(x), yo, y)))
    return x
end
function _mergesort!(::typeof(==), ::typeof(<) xo::ForwardOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(eachindex(x), firstindex(y):nearbefore(last(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(Forward, Reverse, x, view(y, firstindex(y):near(last(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(==), xo::ReverseOrdering, yo::ReverseOrdering, x, y)
    unsafe_mergesort!(eachindex(x), nearafter(last(x), yo, y):lastindex(y), xo, yo, x, y)
    unsafe_appendsort!(Reverse, Reverse, x, view(y, firstindex(y):near(last(x), yo, y)))
    return x
end
function _mergesort!(::typeof(>), ::typeof(==), xo::ReverseOrdering, yo::ForwardOrdering, x, y)
    unsafe_mergesort!(eachindex(x), firstindex(y):nearbefore(last(x), yo, y), xo, yo, x, y)
    unsafe_appendsort!(Reverse, Forward, x, view(y, near(last(x), yo, y):lastindex(y)))
    return x
end


# overlap (spans completely overlap)
_mergesort!(cmpmin::typeof(==), cmpmax::typeof(==) xo::ForwardOrdering, yo, x, y) =
    unsafe_mergesort!(eachindex(x), eachindex(y), xo, yo, x, y)
_mergesort!(cmpmin::typeof(==), cmpmax::typeof(==), xo::ReverseOrdering, yo, x, y) =
    unsafe_mergesort!(eachindex(x), eachindex(y), xo, yo, x, y)
