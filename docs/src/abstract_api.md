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

### Obligatory methods

```julia
struct APerm{T} <: AbstractPermutations.AbstractPermutation
    images::Vector{T}
    degree::Int

    function APerm{T}(v::AbstractVector{<:Integer}, check::Bool=true, degree=nothing)
        if check
            isperm(v) || throw(ArgumentError("v is not a permutation"))
            if !isnothing(degree) && degree != __degree(v)
                throw(ArgumentError("wrong degree was passed"))
            end
        end
        return new{T}(v, something(degree, __degree(v)))
    end
end

# for our convenience
APerm(v::AbstractVector{T}, check=true) where T = APerm{T}(v, check)
```

Above we defined permutations by storing the vector of their images together
with the computed degree.
For completeness this `__degree`` could be computed as

```julia
function __degree(images::AbstractVector{<:Integer})
    @inbounds for i in lastindex(images):-1:firstindex(images)
        images[i] ≠ i && return i
    end
    return zero(firstindex(images))
end
```

Now we need to implement the remaining two functions which will be simple enough:

```julia
AbstractPermutations.degree(p::APerm) = p.degree
function Base.^(i::T, p::APerm) where {T}
    deg = AbstractPermutations.degree(p)
    # we need to make sure that we return something of type T
    return 1 ≤ i ≤ deg ? convert(T, p.images[i]) : i
end
```

With this the implementation is complete!

### Suplementary Methods

Since in `APerm{T}` we store images as a `Vector{T}`, to avoid spurious
allocations we may define

```julia
AbstractPermutations.inttype(::Type{APerm{T}}) where T = T
```

There is no need to define `AbstractPermutations.perm` as `APerm` is already
very low level and suitable for high performance code-paths.
