using AbstractPermutations
const AP = AbstractPermutations
using Test

include("perms_by_images.jl")
import .ExamplePerms as EP
include("abstract_perm_API.jl")

@testset "AbstractPermutations.jl" begin
    @testset "incomplete implementation" begin
        struct APerm <: AP.AbstractPermutation end

        p = APerm()
        @test_throws AP.InterfaceNotImplemented AP.degree(p)
        @test_throws AP.InterfaceNotImplemented 3^p
    end

    abstract_perm_interface_test(EP.Perm)

    include("parsing.jl")

    include("aperm_interface_check.jl")

    import .APerms
    abstract_perm_interface_test(APerms.APerm)
end
