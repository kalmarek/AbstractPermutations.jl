using Test
import Random

import AbstractPermutations as AP
import AbstractPermutations
include(joinpath(pkgdir(AbstractPermutations), "test", "abstract_perm_API.jl"))

include(joinpath(pkgdir(AbstractPermutations), "test", "perms_by_images.jl"))
import .ExamplePerms as EP

@testset "AbstractPermutations.jl" begin
    include("example_perms_tests.jl")

    @testset "incomplete implementation" begin
        include("aperm_interface_check.jl")
        import .APerms.APerm as APerm

        abstract_perm_interface_test(APerm)

        @test convert(APerm, EP.Perm([2, 3, 1])) isa APerm
        @test convert(APerm, EP.Perm([2, 3, 1])) == EP.Perm([2, 3, 1])
    end

    include("parsing.jl")
end
