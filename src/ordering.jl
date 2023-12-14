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

struct Lex <: Base.Order.Ordering end
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
