const AP = AbstractPermutations

function __degree(images::AbstractVector{<:Integer})
    @inbounds for i in lastindex(images):-1:firstindex(images)
        images[i] ≠ i && return i
    end
    return firstindex(images)
end

mutable struct Perm{T<:Integer} <: AP.AbstractPermutation
    images::Vector{T}
    cycles::AP.CycleDecomposition{T}

    function Perm{T}(
        images::AbstractVector{<:Integer},
        check::Bool = true,
    ) where {T}
        if check && !isperm(images)
            throw(
                ArgumentError(
                    "Provided images do not constitute a permutation!",
                ),
            )
        end
        deg = __degree(images)
        if deg == length(images)
            return new{T}(images)
        else
            # for future: use @time one(Perm{Int})
            # to check if julia can elide the creation of view
            return new{T}(@view images[Base.OneTo(deg)])
        end
    end
end

AP.degree(σ::Perm) = length(σ.images)

Base.Base.@propagate_inbounds function Base.:^(n::Integer, σ::Perm)
    return 1 ≤ n ≤ AP.degree(σ) ? oftype(n, @inbounds σ.images[n]) : n
end

# this would be enough; for convienience we also define those

inttype(::Type{Perm{T}}) where {T} = T
inttype(::Type{Perm}) = UInt16 # the default type when not specified

function Perm(images::AbstractVector{<:Integer}, check = true)
    return Perm{AP.inttype(Perm)}(images, check)
end

# we could also define these to make use of lazy-caching of cycle decomposition
#=
function AP.cycles(σ::Perm)
    if !isdefined(σ, :cycles)
        cdec = AP.CycleDecomposition(σ)
        σ.cycles = cdec
    end
    return σ.cycles
end

function AP.parity(σ::Perm)
    isdefined(σ, :cycles) && return AP.parity(AP.cycles(σ))
    return AP.__parity_generic(σ)
end

=#

# some other performance overloads that are possible
#=
Base.copy(σ::Perm) = Perm(copy(σ.images), false)

=#
