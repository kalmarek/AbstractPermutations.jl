using AbstractPermutations
const AP = AbstractPermutations
using Test

include("perms_by_images.jl")
include("abstract_perm_API.jl")

@testset "AbstractPermutations.jl" begin
    abstract_perm_interface_test(Perm)
end
