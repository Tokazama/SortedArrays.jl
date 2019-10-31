using SortedArrays: index_orders
@testset "vcatsort" begin
    for (xo, yo, x, y, ret, cmp) in (
     (Forward, Forward, [1, 2, 3], [4, 5, 6], ((1:3, nothing, nothing), (nothing, nothing, 1:3)), "< < gap"),
     (Forward, Forward, [1, 2, 3], [2, 3, 4], ((1:2,     3:3, nothing), (nothing,     1:2, 3:3)), "< <"),
     (Forward, Forward, [1, 2, 5], [2, 3, 4], [1, 2, 2, 3, 4, 5], "< >"),
     (Forward, Forward, [1, 3, 5], [2, 3, 5], [1, 2, 3, 3, 5, 5], "< =="),
     (Forward, Forward, [3, 4, 5], [1, 3, 6], [1, 3, 3, 4, 5, 6], "> <"),
     (Forward, Forward, [4, 5, 6], [1, 2, 3], [1, 2, 3, 4, 5, 6], "> > gap"),
     (Forward, Forward, [3, 4, 5], [1, 2, 4], [1, 2, 3, 4, 4, 5], "> >"),
     (Forward, Forward, [3, 4, 5], [1, 2, 5], [1, 2, 3, 4, 5, 5], "> =="),
     (Forward, Forward, [3, 4, 7], [3, 5, 6], [3, 3, 4, 5, 6, 7], "== <"),
     (Forward, Forward, [3, 6, 7], [3, 4, 5], [3, 3, 4, 5, 6, 7], "== >"),
     (Forward, Forward, [3, 6, 7], [3, 5, 7], [3, 3, 5, 6, 7, 7], "== =="),

     (Forward, Reverse, [1, 2, 3], [6, 5, 4], [1, 2, 3, 4, 5, 6], "< < gap"),
     (Forward, Reverse, [1, 2, 3], [4, 3, 2], [1, 2, 2, 3, 3, 4], "< <"),
     (Forward, Reverse, [1, 2, 5], [4, 3, 2], [1, 2, 2, 3, 4, 5], "< >"),
     (Forward, Reverse, [1, 3, 5], [5, 3, 2], [1, 2, 3, 3, 5, 5], "< =="),
     (Forward, Reverse, [3, 4, 5], [6, 3, 1], [1, 3, 3, 4, 5, 6], "> <"),
     (Forward, Forward, [4, 5, 6], [3, 2, 1], [1, 2, 3, 4, 5, 6], "> > gap"),
     (Forward, Reverse, [3, 4, 5], [4, 2, 1], [1, 2, 3, 4, 4, 5], "> >"),
     (Forward, Reverse, [3, 4, 5], [5, 2, 1], [1, 2, 3, 4, 5, 5], "> =="),
     (Forward, Reverse, [3, 4, 7], [6, 5, 3], [3, 3, 4, 5, 6, 7], "== <"),
     (Forward, Reverse, [3, 6, 7], [5, 4, 3], [3, 3, 4, 5, 6, 7], "== >"),
     (Forward, Reverse, [3, 6, 7], [7, 5, 3], [3, 3, 5, 6, 7, 7], "== =="),

     (Reverse, Forward, [3, 2, 1], [4, 5, 6], [6, 5, 4, 3, 2, 1], "< < gap"),
     (Reverse, Forward, [3, 2, 1], [2, 3, 4], [4, 3, 3, 2, 2, 1], "< <"),
     (Reverse, Forward, [5, 2, 1], [2, 3, 4], [5, 4, 3, 2, 2, 1], "< >"),
     (Reverse, Forward, [5, 3, 1], [2, 3, 5], [5, 5, 3, 3, 2, 1], "< =="),
     (Reverse, Forward, [5, 4, 3], [1, 3, 6], [6, 5, 4, 3, 3, 1], "> <"),
     (Reverse, Forward, [6, 5, 1], [1, 2, 3], [6, 5, 4, 3, 2, 1], "> > gap"),
     (Reverse, Forward, [5, 4, 3], [1, 2, 4], [5, 4, 4, 3, 2, 1], "> >"),
     (Reverse, Forward, [5, 4, 3], [1, 2, 5], [5, 5, 4, 3, 2, 1], "> =="),
     (Reverse, Forward, [7, 4, 3], [3, 5, 6], [7, 6, 5, 4, 3, 3], "== <"),
     (Reverse, Forward, [7, 6, 3], [3, 4, 5], [7, 6, 5, 4, 3, 3], "== >"),
     (Reverse, Forward, [7, 6, 3], [3, 5, 7], [7, 7, 6, 5, 3, 3], "== =="),

     (Reverse, Reverse, [3, 2, 1], [6, 5, 4], [6, 5, 4, 3, 2, 1], "< < gap"),
     (Reverse, Reverse, [3, 2, 1], [4, 3, 2], [4, 3, 3, 2, 2, 1], "< <"),
     (Reverse, Reverse, [5, 2, 1], [4, 3, 2], [5, 4, 3, 2, 2, 1], "< >"),
     (Reverse, Reverse, [5, 3, 1], [5, 3, 2], [5, 5, 3, 3, 2, 1], "< =="),
     (Reverse, Reverse, [5, 4, 3], [6, 3, 1], [6, 5, 4, 3, 3, 1], "> <"),
     (Reverse, Forward, [6, 5, 1], [3, 2, 1], [6, 5, 4, 3, 2, 1], "> > gap"),
     (Reverse, Reverse, [5, 4, 3], [4, 2, 1], [5, 4, 4, 3, 2, 1], "> >"),
     (Reverse, Reverse, [5, 4, 3], [5, 2, 1], [5, 5, 4, 3, 2, 1], "> =="),
     (Reverse, Reverse, [7, 4, 3], [6, 5, 3], [7, 6, 5, 4, 3, 3], "== <"),
     (Reverse, Reverse, [7, 6, 3], [5, 4, 3], [7, 6, 5, 4, 3, 3], "== >"),
     (Reverse, Reverse, [7, 6, 3], [7, 5, 3], [7, 7, 6, 5, 3, 3], "== =="),
     (Forward, Forward, [1, 2, 3, 4], [2, 3, 4, 5], [1, 2, 2, 3, 3, 4, 4, 5], "")
                                    )
        @testset "$xo-$yo-$cmp" begin
            @test @inferred(index_orders(xo, yo, x, y)) == ret
        end
    end
end
