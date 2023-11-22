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

    @testset "parsing" begin
        @test isone(parse(EP.Perm, ""))
        @test_throws ArgumentError parse(EP.Perm, "(1,2,3")
        @test_throws ArgumentError parse(EP.Perm, "(1,2,3),(4,5)")
        @test_throws ArgumentError parse(EP.Perm, "(1,2,3),(4 5)")
    end
end
