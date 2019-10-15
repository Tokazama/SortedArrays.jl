module SortedArrays

using Base.Order
using Base: @propagate_inbounds

export
    SortedVector,
    can_growfirst,
    can_growlast,
    growlast!,
    growfirst!,
    shrinklast!,
    shrinkfirst!,
    can_setstep,
    setfirst!,
    setlast!,
    setstep!,
    has_step,
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
    prevtype

include("traits.jl")
include("shrink.jl")
include("grow.jl")
include("sortedvector.jl")
include("sortedrange.jl")
include("vecrange.jl")

end # module
