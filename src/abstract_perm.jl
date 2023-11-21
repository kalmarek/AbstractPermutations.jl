"""
    AbstractPermutation
Abstract type representing bijections of positive integers `ℕ = {1,2,…}`
finitely supported. That is, we treat permutations as functions `ℕ → ℕ` such
that for every permutation `σ` there are only finitely many `k` different from
their image under `σ`.

# Mandatory interface
Subtypes `APerm <: AbstractPermutation` must implement the following functions:
* `APerm(images::AbstractVector{<:Integer}[, check::Bool=true])` - a
  constructor of a `APerm` from a vector of images. Optionally the second
  argument `check` may be set to `false` when the caller knows that `images`
  constitute a honest permutation.
* [`Base.:^(i::Integer, σ::APerm)`](@ref ^(::Integer, ::AbstractPermutation))
  the customary notation for the image of `i` under `σ`.
* [`degree(σ::APerm)`](@ref degree) the minimal `d ≥ 1` such that `σ` fixes all
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
"""
abstract type AbstractPermutation <: GroupsCore.GroupElement end

"""
    degree(σ::AbstractPermutation)
Return a minimal number `n ≥ 1` such that `σ(k) == k` for all `k > n`,

Such number `n` can be understood as a _degree_ of a permutation, since we can
regard `σ` as an element of `Sym(1:n)` (and not of `Sym(1:n-1)`).

!!! note
    By this convention `degree` of the trivial permutation is equal to `1` and
    it is the only permutation with this property.
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
Return the image of `i` under `σ`.

We consider `σ` as a permutation of `ℕ` (the positive integers), with finite
support, so by convention `k^σ = k` for all `k > degree(σ)`.

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
    perm(p::AbstractPermutation)
Return the "bare-metal" permutation (unwrap).

!!! warn
    **For internal use only.**

Access to wrapped permutation object. For "bare-metal" permutations this needs
to return the identical (i.e. ``===`) object. The intention of ths functions
is to provide un-wrapped permutations to computationally intensive algorithms,
so that the external wrappers (if exist) do not hinder the performance.
"""
perm(p::AbstractPermutation) = p

"""
    inttype(σ::Type{<:AbstractPermutation})
Return the underlying "storage" integer.

!!! warn
    **For internal use only.**

The intension is to provide optimal storage type when the `images` vector
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

function __images_vector(p::AbstractPermutation, n = degree(p))
    return inttype(p)[i^p for i in Base.OneTo(n)]
end

function Base.convert(
    ::Type{P},
    p::AbstractPermutation,
) where {P<:AbstractPermutation}
    return P(__images_vector(p), false)
end

Base.one(::Type{P}) where {P<:AbstractPermutation} = P(inttype(P)[1], false)
Base.one(σ::AbstractPermutation) = one(typeof(σ))
Base.isone(σ::AbstractPermutation) = degree(σ) == 1

function _deepcopy(p::AbstractPermutation)
    return typeof(p)(__images_vector(p), false)
end

function Base.deepcopy_internal(p::AbstractPermutation, stackdict::IdDict)
    haskey(stackdict, p) && return stackdict[p]
    return _deepcopy(p)
end

Base.copy(p::AbstractPermutation) = _deepcopy(p)

function Base.:(==)(σ::AbstractPermutation, τ::AbstractPermutation)
    degree(σ) ≠ degree(τ) && return false
    @inbounds for i in Base.OneTo(degree(σ))
        if i^σ != i^τ
            return false
        end
    end
    return true
end

function Base.hash(σ::AbstractPermutation, h::UInt)
    h = hash(AbstractPermutation, h)
    @inbounds for i in Base.OneTo(degree(σ))
        h = hash(i^σ, h)
    end
    return h
end

Base.broadcastable(p::AbstractPermutation) = Ref(p)

"""
    cycles(g::AbstractPermutation)
Return an iterator over cycles in the disjoint cycle decomposition of `g`.
"""
cycles(σ::AbstractPermutation) = CycleDecomposition(σ)

function CycleDecomposition(σ::AbstractPermutation)
    T = inttype(σ)
    deg = degree(σ)

    # allocate vectors of the expected size
    visited = falses(deg)
    cycles = Vector{T}(undef, deg)
    # expected number of cycles - (overestimation of) the harmonic
    cyclesptr = Vector{T}(undef, 5 + ceil(Int, Base.log(deg + 1)))

    # shrink them accordingly
    resize!(cycles, 0)
    resize!(cyclesptr, 1)
    cyclesptr[begin] = 1

    @inbounds for idx in Base.OneTo(deg)
        visited[idx] && continue
        first_pt = idx

        push!(cycles, first_pt)
        visited[first_pt] = true
        next_pt = first_pt^σ
        while next_pt ≠ first_pt
            push!(cycles, next_pt)
            visited[next_pt] = true
            next_pt = next_pt^σ
        end
        push!(cyclesptr, length(cycles) + 1)
    end
    return CycleDecomposition{T}(cycles, cyclesptr)
end

# IO

function Base.show(io::IO, ::MIME"text/plain", g::AbstractPermutation)
    return _print_perm(io, g)
end

function _print_perm(
    io::IO,
    p::AbstractPermutation,
    width::Integer = last(displaysize(io)),
)
    if isone(p)
        return print(io, "()")
    else
        for c in cycles(p)
            length(c) == 1 && continue
            cyc = join(c, ",")

            if width ≥ length(cyc) + 2
                print(io, "(", cyc, ")")
                width -= length(cyc) + 2
            else
                print(io, "(", SubString(cyc, 1, width - 3), " …")
                break
            end
        end
    end
end
