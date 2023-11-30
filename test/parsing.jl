@testset "parsing cycles" begin
    @test AP._parse_cycles("()") == Int[]
    @test AP._parse_cycles("(1)(2)(3)") == [[1], [2], [3]]
    @test AP._parse_cycles("(1)(2,3)") == [[1], [2, 3]]
    @test AP._parse_cycles("(1)(\n2, 3)") == [[1], [2, 3]]
    @test AP._parse_cycles("(3,2,1)(4,5)") == [[3, 2, 1], [4, 5]]
    @test_throws ArgumentError AP._parse_cycles("(a,b)")
    @test_throws ArgumentError AP._parse_cycles("(1 2)")

    s = """
    ( 1, 22,73,64,78,81,  24 ,89,90,54,51,82,91,53, 18
    ,38,19,52,44,77,62,95,94,50,43,42,
    10,67,87,60,36,12)(2,57,34,88)(3,92,76,17,99,96,30,55,45,41,98)(4,56,59,97,49,
    21,15,9,26,86,83,29,27,66,6,58,28,5,68,40,72,7,84,93,39,79,23,46,63,32,61,100,
    11)(8,80,71,75,35,14,85,25,20,70,65,16,48,47,37,74,33,13,31,69)
    """

    s2 = """
    (1,22,73,64,78,81,24,89,90,54,51,82,91,53,18,38,19,52,44,77,62,95,94,50,43,42,\n10,67,87,60,36,12)(2,57,34,88)(3,92,76,17,99,96,30,55,45,41,98)(4,56,59,97,49,\n21,15,9,26,86,83,29,27,66,6,58,28,5,68,40,72,7,84,93,39,79,23,46,63,32,61,100,\n11)(8,80,71,75,35,14,85,25,20,70,65,16,48,47,37,74,33,13,31,69)
    """
    @test AP._parse_cycles(s) == AP._parse_cycles(s2)
end

@testset "@perm macro" begin
    P = EP.Perm

    @test_throws ArgumentError parse(P, "(1,2,3")
    @test_throws ArgumentError parse(P, "(1,2,3),(4,5)")
    @test_throws ArgumentError parse(P, "(1,2,3),(4 5)")

    images = [2, 3, 1]
    @test parse(P{UInt8}, "(1,2,3)(5)(10)") == P{UInt8}(images)
    @test parse(P{UInt32}, "(1,2,3)(5)(10)") == P{UInt32}(images)

    @test AP.@perm(P{UInt16}, "(1,2,3)(5)(10)") isa AP.AbstractPermutation
    @test AP.@perm(P{UInt16}, "(1,2,3)(5)(10)") isa P
    @test AP.@perm(P{UInt16}, "(1,2,3)(5)(10)") isa P{UInt16}
    @test AP.@perm(P{Int8}, "(1,2,3)(5)(10)") isa P{Int8}

    @test AP.degree(AP.@perm(P{UInt16}, "(1,2,3)(5)(10)")) == 3
    @test AP.@perm(P{UInt16}, "(1,2,3,4,5)") == P([2, 3, 4, 5, 1])
    @test AP.@perm(P{UInt16}, "(3,2,1)(4,5)") == P([3, 1, 2, 5, 4])

    @test eltype([AP.@perm(P{UInt16}, "(1,2)"), P([2, 3, 4, 5, 1])]) ==
          P{UInt16}
end
