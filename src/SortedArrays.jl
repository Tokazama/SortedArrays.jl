module SortedArrays

using Base.Order
using Base: @propagate_inbounds, tail, front, OneTo

using StaticRanges

using StaticRanges: can_setstep, can_setfirst, can_setlast, Fix2

export
    SortedVector,
    growlast!,
    growfirst!,
    shrinklast!,
    shrinkfirst!,
    isbefore,
    isafter,
    isbefore,
    iswithin,
    iscontiguous,
    isforward,
    isreverse,
    isordered,
    findclosest,
    findorder,
    order,
    getbefore,
    getafter,
    getwithin,
    nexttype,
    prevtype,
    vcatsort

include("traits.jl")
include("shrink.jl")
include("grow.jl")
include("sortedvector.jl")
include("sortedrange.jl")
include("vecrange.jl")
include("getindex.jl")
include("setindex.jl")
#include("index_orders.jl")
include("vcat.jl")
include("find.jl")
#include("")

end # module
