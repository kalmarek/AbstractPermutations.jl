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

    @testset "ExamplePerms" begin
        abstract_perm_interface_test(EP.Perm)

        p = EP.Perm([1]) # ()
        a = EP.Perm([2, 1, 3]) # (1,2)
        b = EP.Perm([2, 3, 1]) # (1,2,3)
        c = EP.Perm([1, 2, 3, 5, 4]) # (4,5)

        @test contains(sprint(show, MIME"text/plain"(), p), "()")
        @test contains(sprint(show, MIME"text/plain"(), a), "(1,2)")
        @test contains(sprint(show, MIME"text/plain"(), b), "(1,2,3)")
        @test contains(sprint(show, MIME"text/plain"(), c), "(4,5)")
        @test contains(sprint(show, MIME"text/plain"(), b * c), "(1,2,3)(4,5)")
    end

    include("parsing.jl")

    include("aperm_interface_check.jl")

    import .APerms
    abstract_perm_interface_test(APerms.APerm)
end
