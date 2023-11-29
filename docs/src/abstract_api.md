```@meta
CurrentModule = AbstractPermutations
```

# The `AbstractPermutation` interface

The `AbstractPermutation` interface consists of just three mandatory functions.
Note that none of them is exported, hence it is safe to `import`/`using`
the package without introducing any naming conflicts with other packages.

There are three obligatory methods are as follows:
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

Moreover there are two more internal, suplementary functions that may be
overloaded by the implementer, if needed.

```@docs
inttype
perm
```

## Example implementation

For an example, very simple implementation of the `AbstractPermutation`
interface you may find in `ExamplePerms` module defined in
[`perms_by_images.jl`](https://github.com/kalmarek/AbstractPermutations.jl/blob/main/test/perms_by_images.jl).

Here we provide an alternative implementation which keeps the internal
storage at fixed length.

### Implementing Obligatory methods

```jldoctest APerm; output=false
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

# for our convenience we define
APerm(v::AbstractVector{T}, check=true) where T = APerm{T}(v, check)

# output
APerm
```

Above we defined permutations by storing the vector of their images together
with the computed degree.
For completeness this `__degree`` could be computed as

```jldoctest APerm; output=false
function __degree(images::AbstractVector{<:Integer})
    @inbounds for i in lastindex(images):-1:firstindex(images)
        images[i] ≠ i && return i
    end
    return zero(firstindex(images))
end

# output
__degree (generic function with 1 method)
```

Now we need to implement the remaining two functions which will be simple enough:

```jldoctest APerm; output=false
AbstractPermutations.degree(p::APerm) = p.degree
function Base.:^(i::Integer, p::APerm)
    deg = AbstractPermutations.degree(p)
    # make sure that we return something of the same type as `i`
    return 1 ≤ i ≤ deg ? oftype(i, p.images[i]) : i
end

# output
```

With this the implementation is complete! To test if the implementation follows the specification a test suite is provided:

```jldoctest APerm; filter = [r"\|\s+(\d+\s+)+(\d+\.\d+s)", r"Test\.DefaultTestSet(.*)"]
include(joinpath(pkgdir(AbstractPermutations), "test", "abstract_perm_API.jl"))
abstract_perm_interface_test(APerm);

# output
Test Summary:                                                    | Pass  Total  Time
AbstractPermutation API test: APerm |   95     95  0.4s
Test.DefaultTestSet("AbstractPermutation API test: APerm", Any[Test.DefaultTestSet("the identity permutation", Any[], 7, false, false, true, 1.701268412377077e9, 1.701268412390534e9, false), Test.DefaultTestSet("same permutations", Any[], 13, false, false, true, 1.701268412390564e9, 1.701268412390592e9, false), Test.DefaultTestSet("group arithmetic", Any[], 11, false, false, true, 1.701268412390603e9, 1.701268412454585e9, false), Test.DefaultTestSet("actions on 1:n", Any[], 23, false, false, true, 1.701268412454622e9, 1.701268412454663e9, false), Test.DefaultTestSet("permutation functions", Any[], 31, false, false, true, 1.701268412454673e9, 1.701268412454732e9, false), Test.DefaultTestSet("io/show and parsing", Any[], 9, false, false, true, 1.70126841245474e9, 1.701268412497615e9, false)], 1, false, false, true, 1.701268412376839e9, 1.70126841249762e9, false)
```

### Suplementary Methods

Since in `APerm{T}` we store images as a `Vector{T}`, to avoid spurious
allocations we may define

```julia
AP.inttype(::Type{APerm{T}}) where T = T
```

There is no need to define `AbstractPermutations.perm` as `APerm` is already
very low level and suitable for high performance code-paths.
