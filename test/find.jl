
using SortedArrays: _findfirst

@testset "find" begin
    for v in (SortedVector([1, 3, 5, 7, 9, 10]),
              reverse(SortedVector([1, 3, 5, 7, 9, 10])))
        @testset "Type: $(typeof(v))" begin
            for i in 1:10
                @testset "Number: $i" begin
                    for f in (<, >, <=, >=, ==)
                        @testset "Comparison: $f" begin
                            @testset "findfirst" begin
                                @test findfirst(f(i), v) == findfirst(f(i), parent(v))
                            end

                            @testset "findlast" begin
                                @test findlast(f(i), v) == findlast(f(i), parent(v))
                            end

                            @testset "findall" begin
                                @test findall(f(i), v) == findall(f(i), parent(v))
                            end

                            @testset "count" begin
                                @test count(f(i), v) == count(f(i), parent(v))
                            end

                            @testset "filter" begin
                                @test filter(f(i), v) == filter(f(i), parent(v))
                            end
                        end
                    end
                end
            end
        end
    end
end
