module ExamplePerms
import AbstractPermutations as AP

function __degree(images::AbstractVector{<:Integer})
    @inbounds for i in lastindex(images):-1:firstindex(images)
        images[i] ≠ i && return i
    end
    return zero(firstindex(images))
end

struct Perm{T<:Integer} <: AP.AbstractPermutation
    images::Vector{T}

    function Perm{T}(
        images::AbstractVector{<:Integer},
        check::Bool = true,
    ) where {T}
        Base.require_one_based_indexing(images)
        if check && (!isperm(images) || isempty(images))
            throw(ArgumentError("images do not constitute a permutation!"))
        end
        deg = __degree(images)
        # we take the ownership of `images`, when possible
        if images isa Vector
            images = resize!(images, deg)
            return new{T}(images) # no copy
        else # fallback, copies view into a new vector
            return new{T}(@view images[Base.OneTo(deg)])
        end
    end
end

AP.degree(σ::Perm) = length(σ.images)

function Base.:^(n::Integer, σ::Perm)
    return n in eachindex(σ.images) ? oftype(n, @inbounds σ.images[n]) : n
end

# this would be enough; for convienience we also define those

AP.inttype(::Type{Perm{T}}) where {T} = T
AP.inttype(::Type{Perm}) = UInt16 # the default type when not specified

function Perm(images::AbstractVector{<:Integer}, check = true)
    return Perm{AP.inttype(Perm)}(images, check)
end

# we also define this function to squeeze more performance
@inline AP.__unsafe_image(n::Integer, σ::Perm) =
    oftype(n, @inbounds σ.images[n])

# to make use of lazy-caching of cycle decomposition the following pattern
# could be used:
#=
mutable struct Perm{T<:Integer} <: AP.AbstractPermutation
    images::Vector{T}
    cycles::AP.CycleDecomposition{T}

    # __same__ (hence incomplete) constructor as above

end

function AP.cycles(σ::Perm)
    if !isdefined(σ, :cycles)
        cdec = AP.CycleDecomposition(σ)
        σ.cycles = cdec
    end
    return σ.cycles
end

function AP.isodd(σ::Perm)
    isdefined(σ, :cycles) && return AP.isodd(AP.cycles(σ))
    return AP.__isodd(σ)
end

=#

# some other performance overloads that are possible
# Base.copy(σ::Perm) = Perm(copy(σ.images), false)

end # of module Perms
