function __unsafe_lex_compare(
    p::AbstractPermutation,
    q::AbstractPermutation,
    deg,
)
    let ^ = __unsafe_image
        for i in Base.OneTo(deg)
            ip = i^p
            iq = i^q
            if ip < iq
                return true
            elseif ip > iq
                return false
            end
        end
    end
end

"""
    Lex <: Base.Order.Ordering
Lexicographical ordering of permutations.

The comparison of permutations `σ` and `τ` in Lexicographical ordering returns
`true` when there exists `k ≥ 1` such that
* `i^σ == i^τ` for all `i < k` and
* `k^σ < k^τ`
and `false` otherwise.

The method `isless(σ::AbstractPermutation, τ::AbstractPermutation)` defaults to
the lexicographical order, i.e. calling `Base.lt(Lex(), σ, τ)`.

See also [`DegLex`](@ref).
"""
struct Lex <: Base.Order.Ordering end

"""
    DegLex <: Base.Order.Ordering
Degree-then-lexicographical ordering of permutations.

The comparison of `σ` and `τ` is made by comparing [`degree`s](@ref degree)
first, and by the [lexicographical ordering](@ref Lex) among permutations
of the same `degree`.

See also [`Lex`](@ref).
"""
struct DegLex <: Base.Order.Ordering end

function Base.isless(p::AbstractPermutation, q::AbstractPermutation)
    return Base.lt(Lex(), p, q)
end

function Base.lt(::Lex, p::AbstractPermutation, q::AbstractPermutation)
    res = __unsafe_lex_compare(p, q, min(degree(p), degree(q)))
    return something(res, degree(p) < degree(q))
end

function Base.lt(::DegLex, p::AbstractPermutation, q::AbstractPermutation)
    degree(p) < degree(q) && return true
    return something(__unsafe_lex_compare(p, q, degree(p)), false)
end
