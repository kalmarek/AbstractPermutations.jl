# AbstractPermutations

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kalmarek.github.io/AbstractPermutations.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kalmarek.github.io/AbstractPermutations.jl/dev/)
[![CI](https://github.com/kalmarek/AbstractPermutations.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/kalmarek/AbstractPermutations.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/kalmarek/AbstractPermutations.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/kalmarek/AbstractPermutations.jl)

This julia package provide a basis for inteoperability between different implementations of permutations in julia.
The interface is based on four preconditions:

* subtyping `AbstractPermutations.AbstractPermutation`, and
* implementing a constructor from vector of `images`, and
* implementing methods for
  * `AbstractPermutations.degree(::AbstractPermutation)` and
  * `Base.^(::Integer, ::AbstractPermutation)`,

and two conventions:

* `AbstractPermutations` are finitely supported bijections of `N` (the positive integers)
* `AbstractPermutations` act on `N` from the right (and therefore `(1,2)·(1,2,3) == (1,3)`).

With implementing the interface one receives not only consistent arithmetic **across** different implementations of the interface but also the possibility to run permutation groups algorithms from package following the interface

The packages following `AbstractPermutation` interface:

* [`PermutationGroups.jl`](https://github.com/kalmarek/PermutationGroups.jl)
* [`PermGroups.jl`](https://github.com/jmichel7/PermGroups.jl/) (to be confirmed).

> Note that [`Permutations.jl`](https://github.com/scheinerman/Permutations.jl) **do not** implement the `AbstractPermutations.jl` interface due to the fact that they act on integers **on the left**. See [these](https://github.com/scheinerman/Permutations.jl/issues/42#issuecomment-1826868005) [comments](https://github.com/scheinerman/Permutations.jl/issues/42#issuecomment-1830242636).

## Testing of the interface

We provide test suite for the interface. Example implementations [`ExamplePerms.Perm`](https://github.com/kalmarek/AbstractPermutations.jl/blob/main/test/perms_by_images.jl) can be tested via the following.

```julia
julia> using AbstractPermutations

julia> include(joinpath(pkgdir(AbstractPermutations), "test", "abstract_perm_API.jl"))
abstract_perm_interface_test (generic function with 1 method)

julia> include(joinpath(pkgdir(AbstractPermutations), "test", "perms_by_images.jl")) # include your own implementation
Main.ExamplePerms

julia> import .ExamplePerms

julia> abstract_perm_interface_test(ExamplePerms.Perm{UInt16});
Test Summary:                                        | Pass  Total  Time
AbstractPermutation API test: Main.ExamplePerms.Perm |   95     95  0.3s

```
