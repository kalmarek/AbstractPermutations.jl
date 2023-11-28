function Base.inv(σ::AbstractPermutation)
    img = Vector{inttype(σ)}(undef, degree(σ))
    @inbounds for i in Base.OneTo(degree(σ))
        img[i^σ] = i
    end
    return typeof(σ)(img, false)
end

function Base.:(*)(σ::AbstractPermutation, τ::AbstractPermutation)
    deg = max(degree(σ), degree(τ))
    img = Vector{inttype(σ)}(undef, deg)
    @inbounds for i in Base.OneTo(deg)
        k = (i^σ)^τ
        img[i] = k
    end
    return typeof(σ)(img, false)
end

function Base.:(*)(
    σ::AbstractPermutation,
    τ::AbstractPermutation,
    ρ::AbstractPermutation,
)
    deg = max(degree(σ), degree(τ), degree(ρ))
    img = Vector{inttype(σ)}(undef, deg)
    @inbounds for i in Base.OneTo(deg)
        k = ((i^σ)^τ)^ρ
        img[i] = k
    end
    return typeof(σ)(img, false)
end

function Base.:(*)(σ::AbstractPermutation, τs::AbstractPermutation...)
    isempty(τs) && return σ
    deg = max(degree(σ), maximum(degree, τs))
    img = Vector{inttype(σ)}(undef, deg)
    @inbounds for i in Base.OneTo(deg)
        j = (i^σ)
        for τ in τs
            j = j^τ
        end
        img[i] = j
    end
    return typeof(σ)(img, false)
end

function Base.:^(σ::AbstractPermutation, τ::AbstractPermutation)
    deg = max(degree(σ), degree(τ))
    img = Vector{inttype(σ)}(undef, deg)
    @inbounds for i in Base.OneTo(deg)
        img[i^τ] = (i^σ)^τ
    end
    P = typeof(σ)
    return P(img, false)
end