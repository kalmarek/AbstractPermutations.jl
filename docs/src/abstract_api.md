```@meta
CurrentModule = AbstractPermutations
```

# The `AbstractPermutation` interface

The `AbstractPermutation` interface consists of just three mandatory functions.
Note that none of them is exported, hence it is safe to `import`/`using`
the package without introducing any naming conflicts with other packages.

## Mandatory methods

The three mandatory methods are:

* a constructor,
* `AbstractPermutations.degree` and
* `Base.^`.

!!! note
    The meaning of `degree` doesn't have a well established tradition in
    mathematics. This is still ok, as long as we define its meaning with care
    for precision and use it in a consistent and predictable way.

```@docs
AbstractPermutation
```

```@docs
degree
```

```@docs
^(::Integer, ::AbstractPermutation)
```

## Suplementary methods

Moreover there are three internal, suplementary functions that may be overloaded
by the implementer, if needed (mostly for performance reasons).

```@docs
inttype
perm
__unsafe_image
```

## Example implementation

For an example, very simple implementation of the `AbstractPermutation`
interface you may find in `ExamplePerms` module defined in
[`perms_by_images.jl`](https://github.com/kalmarek/AbstractPermutations.jl/blob/main/test/perms_by_images.jl).

Here we provide an alternative implementation which keeps the internal
storage at fixed length.

### Implementing mandatory methods

```@example APerm
import AbstractPermutations
struct APerm{T} <: AbstractPermutations.AbstractPermutation
    images::Vector{T}
    degree::Int

    function APerm{T}(v::AbstractVector{<:Integer}, validate::Bool=true) where T
        if validate
            isperm(v) || throw(ArgumentError("v is not a permutation"))
        end
        return new{T}(v, __degree(v))
    end
end
nothing # hide
```

Above we defined permutations by storing the vector of their images together
with the computed degree.
For completeness this `__degree` could be computed as

```@example APerm
function __degree(images::AbstractVector{<:Integer})
    k = findlast(i->images[i] ≠ i, eachindex(images))
    return something(k, 0)
end
nothing # hide
```

Now we need to implement the remaining two functions which will be simple enough:

```@example APerm
AbstractPermutations.degree(p::APerm) = p.degree
function Base.:^(i::Integer, p::APerm)
    deg = AbstractPermutations.degree(p)
    # make sure that we return something of the same type as `i`
    return 1 ≤ i ≤ deg ? oftype(i, p.images[i]) : i
end
nothing # hide
```

With this the interface is implementation is complete. To test whether the implementation
follows the specification a test suite is provided:

```@example APerm
include(joinpath(pkgdir(AbstractPermutations), "test", "abstract_perm_API.jl"))
abstract_perm_interface_test(APerm{UInt16})
nothing # hide
```

### Suplementary Methods

Since in `APerm{T}` we store images as a `Vector{T}`, to avoid spurious
allocations we may define

```julia
AbstractPermutations.inttype(::Type{APerm{T}}) where T = T
```

There is no need to define `AbstractPermutations.perm` as `APerm` is already
very low level and suitable for high performance code-paths.

Finally to squeeze even more performance one could define `__unsafe_image`
with the same semantics as `n^σ` under the assumption that `n` belongs to
`Base.OneTo(degree(σ))`:

```julia
@inline function AbstractPermutations.__unsafe_image(n::Integer, σ::APerm)
    return oftype(n, @inbounds σ.images[n])
end
```
