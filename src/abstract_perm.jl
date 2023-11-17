"""
    AbstractPermutation
Abstract type representing permutations of set `1:n` for some `n`.

# Mandatory interface
Subtypes `APerm <: AbstractPermutation` must implement the following functions:
 * `Base.:^(i::Integer, σ::APerm)` - the image of `i` under `σ`,
 * `degree(σ::APerm)` - the **minimal** `n` such that `k^σ == k` for all `k > n`,

For primitive ("bare-metal"/"parent-less") permutations one needs to implement
 * `APerm(images::AbstractVector{<:Integer}[, check::Bool=true])` - construct a
   `APerm` from a vector of images. Optionally the second argument `check` may be
    set to `false` when the caller knows that `images` constitute a honest
    permutation.

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
 * `inttype(::Type{<:APerm}) = UInt32` - return the underlying "storage" integer,
 if that makes any sense for `APerm`.
 * `perm(σ::APerm) = σ` - return the "bare-metal" permutation (unwrap).
"""
abstract type AbstractPermutation <: GroupsCore.GroupElement end

"""
    degree(σ::AbstractPermutation)
Return a minimal number `n` such that `σ(k) == k` for all `k > n`.

Such number `n` can be understood as a _degree_ of a permutation, since we can
regard `σ` as an element of `Sym(n)` (and not of `Sym(n-1)`).

By convention `degree` of the trivial permutation must return `1`.
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
Return the image of `i` under the (permutation) action of `σ`.

We consider `σ` as a finite support permutation of `ℕ`, so by convention `k^σ = k`
for all `k > degree(σ)`.
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
Return the "bare-metal" permutation (unwrap). **For internal use only.**

Access to wrapped permutation object. For "bare-metal" permutations this needs
to return the identical (i.e. ``===`) object.
"""
perm(p::AbstractPermutation) = p

"""
    inttype(σ::Type{<:AbstractPermutation})
Return the underlying "storage" integer. **For internal use only.**

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
