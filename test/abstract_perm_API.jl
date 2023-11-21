function abstract_perm_interface_test(P::Type{<:AP.AbstractPermutation})
    @testset "AbstractPermutation API test: $P" begin
        @test P([1]) isa AP.AbstractPermutation
        @test_throws ArgumentError P([2])
        @test_throws ArgumentError P([1, 2, 3, 1])

        p = P([1])
        @test one(p) isa AP.AbstractPermutation

        @testset "the identity permutation" begin
            a = P([1, 2, 3])
            @test isone(a)
            @test a == one(a)
            @test isone(one(a))
            @test isone(AP.degree(a))
            @test AP.degree(a) == 1

            @test collect(AP.cycles(a)) == [[1]]

            @test all(i -> i^a == i, 1:5)
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
            p = P([1])
            a = P([2, 1, 3]) # (1,2)
            b = P([2, 3, 1]) # (1,2,3)
            c = P([1, 2, 3, 5, 4]) # (4,5)

            # correctness of action
            @test 1^a == 2
            @test 2^a == 1
            @test (3:7) .^ a == 3:7
            @test (1:5) .^ b == [2, 3, 1, 4, 5]
            @test (1:10) .^ p == 1:10

            # action preserves type
            @test UInt128(1)^a isa UInt128
            @test UInt32(100)^a isa UInt32
            @test UInt8(100)^p isa UInt8

            @test AP.firstmoved(a) == 1
            @test AP.firstmoved(b) == 1
            @test AP.firstmoved(c) == 4
            @test AP.firstmoved(p) === nothing

            @test AP.nfixedpoints(p) == 1
            @test AP.nfixedpoints(b) == 0
            @test AP.nfixedpoints(b, 2:5) == 2
            @test AP.nfixedpoints(c) == 3
            @test AP.nfixedpoints(c, 4:5) == 0

            @test AP.fixedpoints(b) == Int[]
            @test AP.fixedpoints(b, 2:5) == [4, 5]
            @test AP.fixedpoints(c) == [1, 2, 3]
            @test AP.fixedpoints(c, 2:4) == [2, 3]
            @test AP.fixedpoints(p) == [1]
        end

        @testset "permutation functions" begin
            p = P([1]) # ()
            a = P([2, 1, 3]) # (1,2)
            b = P([2, 3, 1]) # (1,2,3)
            c = P([1, 2, 3, 5, 4]) # (4,5)
            @test AP.permtype(p) == Int[]
            @test AP.permtype(a) == [2]
            @test AP.permtype(b) == [3]
            @test AP.permtype(b * c) == [3, 2]

            @test sign(p) == 1
            @test sign(a) == -1
            @test sign(b) == 1
            @test sign(c) == -1
            @test sign(a * b) == -1
            @test sign(a * b * c) == 1

            @test AP.parity(p) == 0
            @test AP.parity(a) == 1
            @test AP.parity(b) == 0
            @test AP.parity(a * b) == 1
            @test AP.parity(a * b * c) == 0

            @test AP.parity(AP.cycles(p)) == 0
            @test AP.parity(AP.cycles(a)) == 1
            @test AP.parity(AP.cycles(b)) == 0
            @test AP.parity(AP.cycles(a * b)) == 1
            @test AP.parity(AP.cycles(a * b * c)) == 0

            @test AP.order(p) == 1
            @test AP.order(a) == 2
            @test AP.order(b) == 3
            @test AP.order(c) == 2
            @test AP.order(b * c) == 6
            @test AP.order(a * b) == 2
            @test AP.order(a * b * c) == 2

            @test collect(AP.cycles(p)) == [[1]]
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
            @test sprint(show, MIME"text/plain"(), p) == "()"
            @test sprint(show, MIME"text/plain"(), a) == "(1,2)"
            @test sprint(show, MIME"text/plain"(), b) == "(1,2,3)"
            @test sprint(show, MIME"text/plain"(), c) == "(4,5)"
            @test sprint(show, MIME"text/plain"(), b * c) == "(1,2,3)(4,5)"

            @test sprint(show, AP.cycles(b)) == "Cycle Decomposition: (1,2,3)"
            @test sprint(show, AP.cycles(b * c)) ==
                  "Cycle Decomposition: (1,2,3)(4,5)"

            @test parse(P, "(1,3)(2,4,6)(3,5)") isa AP.AbstractPermutation
            @test parse(P, "(1,3)(2,4,6)(3,5)") == P([5, 4, 1, 6, 3, 2])

        end
    end
end
