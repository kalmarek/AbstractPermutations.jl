module APerms

using Test
import AbstractPermutations as AP

export APerm

struct APerm <: AP.AbstractPermutation
    images::Vector{Int}
    APerm(images, check::Bool = true) = new(images) # no checks :)
end

@testset "Implementing AbstractPermutation interface" begin
    @test one(APerm) isa AP.AbstractPermutation

    @test_throws AP.InterfaceNotImplemented AP.degree(one(APerm))

    function AP.degree(p::APerm)
        return something(findlast(i -> p.images[i] ≠ i, eachindex(p.images)), 0)
    end

    @test AP.degree(one(APerm)) == 0

    @test_throws AP.InterfaceNotImplemented 5^one(APerm)

    function Base.:^(i::Integer, p::APerm)
        return 1 ≤ i ≤ AP.degree(p) ? oftype(i, p.images[i]) : i
    end

    @test 5^one(APerm) == 5

    @test AP.inttype(one(APerm)) == UInt32
    # but actually it'd be better to have it as Int64
    a = APerm([1, 2, 3])
    b = APerm([2, 3, 1])
    a * b
    k1 = @allocated a * b
    AP.inttype(::Type{APerm}) = Int

    a * b
    k2 = @allocated a * b
    @test k2 < k1
end

end
