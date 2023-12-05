using Test
import AbstractPermutations as AP
function abstract_perm_interface_test(P::Type{<:AP.AbstractPermutation})
    @testset "AbstractPermutation API test: $P" begin
        @test P([1]) isa AP.AbstractPermutation
        try
            P([2])
            @warn "$P doesn't perform image vector validation, use it with care!"
        catch e
            if !(e isa ArgumentError)
                rethrow(e)
            end
        end

        try
            P([1, 2, 3, 1])
            @warn "$P doesn't perform image vector validation, use it with care!"
        catch e
            if !(e isa ArgumentError)
                rethrow(e)
            end
        end

        @testset "the identity permutation" begin
            id = P([1, 2, 3])
            @test isone(id)
            @test one(id) isa AP.AbstractPermutation
            @test id == one(id)
            @test isone(one(id))
            @test AP.degree(id) == 0

            @test collect(AP.cycles(id)) == Vector{Int}[]

            @test all(i -> i^id == i, 1:5)
        end

        @testset "same permutations" begin
            vec = [3, 1, 2, 4]
            a = P(vec)
            a_ = P(vec[1:3])
            @test !isone(a)
            @test !isone(a_)
            @test AP.degree(a) == 3
            @test AP.degree(a_) == 3

            @test a == a_
            @test a_ == P(vec)

            @test hash(a) == hash(a_)
            @test length(unique([a, a_])) == 1

            @test inv(a) isa AP.AbstractPermutation
            @test isone(inv(a) * a)
            @test isone(a * inv(a))

            @test isone(inv(a_) * a)
            @test isone(inv(a) * P(vec))
        end

        @testset "group arithmetic" begin
            a = P([2, 1, 3]) # (1,2)
            b = P([2, 3, 1]) # (1,2,3)

            @test a * b == P([3, 2, 1]) # (1,2)*(1,2,3) == (1,3)
            @test b * a == P([1, 3, 2]) # (1,2,3)*(1,2) == (2,3)
            @test isone(a * a)
            @test isone(b * b * b)

            @test a^b == P([1, 3, 2]) # (1,2)^(1,2,3) == (2,3)
            @test b^a == P([3, 1, 2]) # (1,2,3)^(1,2) == (1,3,2)

            @test *(b) == b
            @test b * b == b^2
            @test b * b * a * a * b == one(b)
            @test b * b * b * b == b^4

            @test Set(b^i for i in 1:10) == Set([b^i for i in 0:2])
        end

        @testset "actions on 1:n" begin
            id = P([1]) # ()
            a = P([2, 1, 3]) # (1,2)
            b = P([2, 3, 1]) # (1,2,3)
            c = P([1, 2, 3, 5, 4]) # (4,5)

            # correctness of action
            @test 1^a == 2
            @test 2^a == 1
            @test (3:7) .^ a == 3:7
            @test (1:5) .^ b == [2, 3, 1, 4, 5]
            @test (1:10) .^ id == 1:10

            # action preserves type
            @test UInt128(1)^a isa UInt128
            @test UInt32(100)^a isa UInt32
            @test UInt8(100)^id isa UInt8

            @test AP.firstmoved(a, 1:AP.degree(a)) == 1
            @test AP.firstmoved(b, 2:5) == 2
            @test AP.firstmoved(c, 1:3) === nothing
            @test AP.firstmoved(c, 1:5) == 4
            @test AP.firstmoved(id, 5:10) === nothing

            @test AP.nfixedpoints(id, 1:AP.degree(id)) == 0
            @test AP.nfixedpoints(b, 1:AP.degree(b)) == 0
            @test AP.nfixedpoints(b, 2:5) == 2
            @test AP.nfixedpoints(c, 1:AP.degree(c)) == 3
            @test AP.nfixedpoints(c, 4:5) == 0

            @test AP.fixedpoints(b, 1:AP.degree(b)) == Int[]
            @test AP.fixedpoints(b, 2:5) == [4, 5]
            @test AP.fixedpoints(c, 1:3) == [1, 2, 3]
            @test AP.fixedpoints(c, 2:4) == [2, 3]
            @test AP.fixedpoints(id, 5:7) == 5:7
        end

        @testset "permutation functions" begin
            id = P([1]) # ()
            a = P([2, 1, 3]) # (1,2)
            b = P([2, 3, 1]) # (1,2,3)
            c = P([1, 2, 3, 5, 4]) # (4,5)
            @test AP.permtype(id) == Int[]
            @test AP.permtype(a) == [2]
            @test AP.permtype(b) == [3]
            @test AP.permtype(b * c) == [3, 2]

            @test sign(id) == 1
            @test sign(a) == -1
            @test sign(b) == 1
            @test sign(c) == -1
            @test sign(a * b) == -1
            @test sign(a * b * c) == 1

            @test isodd(id) == false == !iseven(id)
            @test isodd(a) == true == !iseven(a)
            @test isodd(b) == false == !iseven(b)
            @test isodd(a * b) == true == !iseven(a * b)
            @test isodd(a * b * c) == false == !iseven(a * b * c)

            @test iseven(AP.cycles(id))
            @test isodd(AP.cycles(a))
            @test iseven(AP.cycles(b))
            @test isodd(AP.cycles(a * b))
            @test iseven(AP.cycles(a * b * c))

            @test AP.order(id) == 1
            @test AP.order(a) == 2
            @test AP.order(b) == 3
            @test AP.order(c) == 2
            @test AP.order(b * c) == 6
            @test AP.order(a * b) == 2
            @test AP.order(a * b * c) == 2

            @test collect(AP.cycles(a)) == [[1, 2]]
            @test collect(AP.cycles(b)) == [[1, 2, 3]]
            @test collect(AP.cycles(a * b)) == [[1, 3], [2]]
            @test collect(AP.cycles(b * c)) == [[1, 2, 3], [4, 5]]
        end

        @testset "io/show and parsing" begin
            p = P([1]) # ()
            a = P([2, 1, 3]) # (1,2)
            b = P([2, 3, 1]) # (1,2,3)
            c = P([1, 2, 3, 5, 4]) # (4,5)

            @test sprint(show, AP.cycles(b)) == "Cycle Decomposition: (1,2,3)"
            @test sprint(show, AP.cycles(b * c)) ==
                  "Cycle Decomposition: (1,2,3)(4,5)"

            @test parse(P, "(1,3)(2,4,6)(3,5)") isa AP.AbstractPermutation
            @test parse(P, "(1,3)(2,4,6)(3,5)") == P([5, 4, 1, 6, 3, 2])
            @test deepcopy(c) == c
            @test deepcopy(c) !== c
        end
    end
end
