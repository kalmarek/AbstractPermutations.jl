"""
    parity(g::AbstractPermutation)
Return the parity of number of factors in factorization of `g` into transpositions.

Return `1` if the number is odd and `0` otherwise.
"""
parity(σ::AbstractPermutation) = __parity_generic(σ)
parity(cd::CycleDecomposition) = Int(isodd(count(iseven ∘ length, cd)))

function __parity_generic(σ::AbstractPermutation)
    to_visit = trues(degree(σ))
    parity = false
    k = 1
    @inbounds while any(to_visit)
        k = findnext(to_visit, k)
        to_visit[k] = false
        next = k^σ
        while next != k
            parity = !parity
            to_visit[next] = false
            next = next^σ
        end
    end
    return Int(parity)
end

"""
    sign(g::AbstractPermutation)
Return the sign of a permutation.

`sign` represents the homomorphism from the permutation group to the unit group
of `ℤ` whose kernel is the alternating group.
"""
Base.sign(σ::AbstractPermutation) = ifelse(isone(parity(σ)), -1, 1)

"""
    permtype(g::AbstractPermutation)
Return the group-theoretic type of permutation `g`, i.e. the vector of lengths
of cycles in the (disjoint) cycle decomposition of `g`.

The lengths are sorted in decreasing order and cycles of length `1` are omitted.
`permtype(g)` fully determines the conjugacy class of `g` in the full symmetric group.
"""
function permtype(σ::AbstractPermutation)
    return sort!([length(c) for c in cycles(σ) if length(c) > 1]; rev = true)
end

"""
    firstmoved(g::AbstractPermutation[, range = 1:degree(g)])
Return the first point from `range` that is moved by `g`, or `nothing`
if `g` fixes `range` point-wise.
"""
function firstmoved(σ::AbstractPermutation, range = Base.OneTo(degree(σ)))
    all(>(degree(σ)), range) && return nothing
    for i in range
        if i^σ ≠ i
            return i
        end
    end
    return nothing
end

"""
    fixedpoints(g::AbstractPermutation[, range = 1:degree(g)])
Return the vector of points in `range` fixed by `g`.
"""
function fixedpoints(σ::AbstractPermutation, range = Base.OneTo(degree(σ)))
    all(>(degree(σ)), range) && return eltype(range)[]
    return [i for i in range if i^σ == i]
end

"""
    nfixedpoints(g::AbstractPermutation[, range = 1:degree(g)])
Return the number of points in `range` fixed by `g`.
"""
function nfixedpoints(σ::AbstractPermutation, range = Base.OneTo(degree(σ)))
    return count(i -> i^σ == i, range)
end

function GroupsCore.order(::Type{T}, σ::AbstractPermutation) where {T}
    isone(σ) && return one(T)
    return GroupsCore.order(T, cycles(σ))
end

function GroupsCore.order(::Type{T}, cd::CycleDecomposition) where {T}
    return convert(T, mapreduce(length, lcm, cd; init = 1))
end
