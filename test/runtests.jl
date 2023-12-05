using Test
import Random

import AbstractPermutations as AP
import AbstractPermutations
include(joinpath(pkgdir(AbstractPermutations), "test", "abstract_perm_API.jl"))

include(joinpath(pkgdir(AbstractPermutations), "test", "perms_by_images.jl"))
import .ExamplePerms as EP

@testset "AbstractPermutations.jl" begin
    @testset "incomplete implementation" begin
        struct APerm <: AP.AbstractPermutation end

        p = APerm()
        @test_throws AP.InterfaceNotImplemented AP.degree(p)
        @test_throws AP.InterfaceNotImplemented 3^p
    end

    include("example_perms_tests.jl")

    include("parsing.jl")

    include("aperm_interface_check.jl")

    import .APerms
    abstract_perm_interface_test(APerms.APerm)

    @test convert(APerm, EP.Perm([2, 3, 1])) isa APerm
    @test convert(APerm, EP.Perm([2, 3, 1])) == EP.Perm([2, 3, 1])
end
