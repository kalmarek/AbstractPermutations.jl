"""
    AbstractPermutation
Abstract type representing bijections of positive integers `ℕ = {1,2,…}`
finitely supported. That is, we treat permutations as functions `ℕ → ℕ` such
that for every permutation `σ` there are only finitely many `k` different from
their image under `σ`.

# Mandatory interface
Subtypes `APerm <: AbstractPermutation` must implement the following functions:
* `APerm(images::AbstractVector{<:Integer}[; check::Bool=true])` - a
  constructor of a `APerm` from a vector of images. Optionally the keyword
  argument `check` may be set to `false` when the caller knows that `images`
  constitute a honest permutation.
* [`Base.:^(i::Integer, σ::APerm)`](@ref ^(::Integer, ::AbstractPermutation))
  the customary notation for the image of `i` under `σ`.
* [`degree(σ::APerm)`](@ref degree) the minimal `d ≥ 0` such that `σ` fixes all
  `k ≥ d`.

!!! note
    There is no formal requirement that the `APerm(images)` constructor actually
    returns a `APerm`. Any `AbstractPermutation` object would do. This may be
    useful if constructing permutation from images is not technically feasible.

!!! note
    If `APerm` is not constructable from type one needs to implement `one(::APerm)`.

!!! warn
    Even though `AbstractPermutation <: GroupsCore.GroupElement` they don't
    necessarily implement the whole of `GroupElement` interface, e.g. it is
    possible to implement `parent`-less permutations.

# Optional interface
* [`perm(σ::APerm)`](@ref perm) by default returns `σ` - the "simplest"
  (implementation-wise) permutation underlying `σ`.
* [`inttype(::Type{<:APerm})`](@ref inttype) by default returns `UInt32`.
* [`__unsafe_image(i::Integer, σ::APerm)`](@ref __unsafe_image) defaults to `i^σ`.
"""
abstract type AbstractPermutation <: GroupsCore.GroupElement end

"""
    degree(σ::AbstractPermutation)
Return a minimal number `n ≥ 0` such that `k^σ == k` for all `k > n`.

Such number `n` can be understood as a _degree_ of a permutation, since we can
regard `σ` as an element of `Sym(n)` (and not of `Sym(n-1)`).

!!! note
    By this convention `degree` of the identity permutation is equal to `0`
    and it is the only permutation with this property.
    Also by this convention there is no permutation with `degree` equal to `1`.
"""
function degree(σ::AbstractPermutation)
    throw(
        GroupsCore.InterfaceNotImplemented(
            :AbstractPermutation,
            "AbstractPermutations.degree(::$(typeof(σ)))",
        ),
    )
end

"""
    ^(i::Integer, σ::AbstractPermutation)
Return the image of `i` under `σ` preserving the type of `i`.

We consider `σ` as a permutation of `ℕ` (the positive integers), with finite
support, so `k^σ = k` for all `k > degree(σ)`.

!!! warn
    The behaviour of `i^σ` for `i ≤ 0` is undefined and can not be relied upon.
"""
function Base.:^(::Integer, σ::AbstractPermutation)
    throw(
        GroupsCore.InterfaceNotImplemented(
            :AbstractPermutation,
            "Base.:^(::Integer, ::$(typeof(σ)))",
        ),
    )
end

"""
    __unsafe_image(i::Integer, σ::AbstractPermutation)
The same as `i^σ`, but assuming that `i ∈ Base.OneTo(degree(σ))`.

!!! warn
    The caller is responsible for checking the assumption.
    Failure to do so may (and probably will) lead to segfaults in the best
    case scenario and to silent data corruption in the worst!.
"""
__unsafe_image(i::Integer, σ::AbstractPermutation) = i^σ

"""
    perm(p::AbstractPermutation)
Return the "bare-metal" permutation (unwrap). Return `σ` by default.

!!! warn
    **For internal use only.**

Provide access to wrapped permutation object. For "bare-metal" permutations this
method needs to return the identical (i.e. ``===`) object.

The intention of this method is to provide an un-wrapped permutations to
computationally intensive algorithms, so that the external wrappers (if present)
do not hinder the performance.
"""
perm(p::AbstractPermutation) = p

"""
    inttype(σ::Type{<:AbstractPermutation})
Return the underlying "storage" integer.

!!! warn
    **For internal use only.**

The intention is to provide optimal storage type when the `images` vector
constructor is used (to save allocations and memory copy).
For example a hypothetic permutation `Perm8` of elements up to length `255`
may alter the default to `UInt8`.

The default is `UInt32`.
"""
inttype(::Type{P}) where {P<:AbstractPermutation} = UInt32
function inttype(σ::AbstractPermutation)
    τ = perm(σ)
    return τ === σ ? inttype(typeof(σ)) : inttype(τ)
end

# utilities for Abstract Permutations

function __images_vector(p::AbstractPermutation)
    img = let ^ = __unsafe_image
        inttype(p)[i^p for i in Base.OneTo(degree(p))]
    end
    return img
end

function Base.convert(
    ::Type{P},
    p::AbstractPermutation,
) where {P<:AbstractPermutation}
    return P(__images_vector(p); check = false)
end

Base.convert(::Type{P}, p::P) where {P<:AbstractPermutation} = p

function Base.one(::Type{P}) where {P<:AbstractPermutation}
    return P(inttype(P)[]; check = false)
end
Base.one(σ::AbstractPermutation) = one(typeof(σ))
Base.isone(σ::AbstractPermutation) = degree(σ) == 0

function _copy_by_images(p::AbstractPermutation)
    return typeof(p)(__images_vector(p); check = false)
end

Base.copy(p::AbstractPermutation) = _copy_by_images(p)

function Base.:(==)(σ::AbstractPermutation, τ::AbstractPermutation)
    degree(σ) ≠ degree(τ) && return false
    deg = degree(σ)
    deg < 2 && return true
    let ^ = __unsafe_image
        ans = true
        k = ifelse(ispow2(deg), deg, prevpow(2, deg))
        for i in Base.OneTo(k)
            ans &= i^σ == i^τ
        end
        ans || return false
        @simd for i in (k+1):degree(σ)
            i^σ != i^τ && return false
        end
    end
    return true
end

function Base.hash(σ::AbstractPermutation, h::UInt)
    h = hash(AbstractPermutation, h)
    h = let ^ = __unsafe_image
        foldl((h, i) -> hash(i^σ, h), Base.OneTo(degree(σ)); init = h)
    end
    return h
end

Base.broadcastable(p::AbstractPermutation) = Ref(p)

"""
    cycles(g::AbstractPermutation)::CycleDecomposition
Return an iterator over cycles in the disjoint cycle decomposition of `g`.
"""
cycles(σ::AbstractPermutation) = CycleDecomposition(σ)

"""
    getindex(v::AbstracArray, p::AbstractPermutation)
Permute array `v`, according to permutation `p`.

Permutations can be applied to any `1`-based array such that that `length(v) ≥ degree(p)`.
"""
function Base.getindex(v::AbstractArray, p::AbstractPermutation)
    vp = similar(v)
    return permute!(vp, v, p)
end

"""
    permute!(dest::AbstractArray, v::AbstractArray, p::AbstractPermutation)
Permute array `v` in-place, storing the result in `dest`, according to permutation `p`.

For the out-of-place version use `v[p]`.

Permutations can be applied to any sufficiently long (`length(v) ≥ degree(p)`) `1`-based array.
"""
function Base.permute!(
    dest::AbstractArray,
    v::AbstractArray,
    p::AbstractPermutation,
)
    Base.require_one_based_indexing(v)
    degp = degree(p)
    if degp > length(v)
        throw(
            ArgumentError(
                "Cannot permute: Permutation degree is larger than array length",
            ),
        )
    end
    @inbounds map!(i -> v[i^p], dest, Base.OneTo(degp))
    if degp < length(v)
        copyto!(dest, degp + 1, v, degp + 1, length(v) - degp)
    end
    return dest
end
