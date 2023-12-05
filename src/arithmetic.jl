function Base.inv(σ::AbstractPermutation)
    img = Vector{inttype(σ)}(undef, degree(σ))
    let ^ = __unsafe_image
        for i in Base.OneTo(degree(σ))
            k = i^σ
            @inbounds img[k] = i
        end
    end
    return typeof(σ)(img, false)
end

function Base.:(*)(σ::AbstractPermutation, τ::AbstractPermutation)
    img = Vector{inttype(σ)}(undef, max(degree(σ), degree(τ)))
    let ^ = __unsafe_image
        if degree(σ) ≤ degree(τ)
            for i in Base.OneTo(degree(σ))
                k = (i^σ)^τ
                @inbounds img[i] = k
            end
            for i in degree(σ)+1:degree(τ)
                k = i^τ
                @inbounds img[i] = k
            end
        else # degree(σ) > degree(τ)
            for i in Base.OneTo(degree(σ))
                k = i^σ
                if k ≤ degree(τ)
                    k = k^τ
                end
                @inbounds img[i] = k
            end
        end
    end
    return typeof(σ)(img, false)
end

function Base.:(*)(
    σ::AbstractPermutation,
    τ::AbstractPermutation,
    ρ::AbstractPermutation,
)
    degσ, degτ, degρ = degree(σ), degree(τ), degree(ρ)
    deg = max(degσ, degτ, degρ)
    img = Vector{inttype(σ)}(undef, deg)
    let ^ = __unsafe_image
        if degσ ≤ degτ ≤ degρ
            for i in Base.OneTo(degσ)
                k = ((i^σ)^τ)^ρ
                @inbounds img[i] = k
            end
            for i in degσ+1:degτ
                k = (i^τ)^ρ
                @inbounds img[i] = k
            end
            for i in degτ+1:degρ
                k = i^ρ
                @inbounds img[i] = k
            end
        elseif degσ ≤ degτ # either degσ ≤ degρ < degτ OR degρ < degσ ≤ dτ
            for i in Base.OneTo(degσ)
                k = (i^σ)^τ
                if k ≤ degρ
                    k = k^ρ
                end
                @inbounds img[i] = k
            end
            for i in (degσ+1):degτ
                k = i^τ
                if k ≤ degρ
                    k = k^ρ
                end
                @inbounds img[i] = k
            end
        elseif degτ < degσ ≤ degρ
            for i in Base.OneTo(degσ)
                k = i^σ
                if k ≤ degτ
                    k = k^τ
                end
                k = k^ρ
                @inbounds img[i] = k
            end
            for i in degσ+1:degρ
                k = i^ρ
                @inbounds img[i] = k
            end
        elseif degτ < degσ # either degτ ≤ degρ < degσ OR degρ < degτ < degσ
            for i in Base.OneTo(degσ)
                k = i^σ
                if k ≤ degτ
                    k = k^τ
                end
                if k ≤ degρ
                    k = k^ρ
                end
                @inbounds img[i] = k
            end
        end
    end
    return typeof(σ)(img, false)
end

function Base.:(*)(σ::AbstractPermutation, τs::AbstractPermutation...)
    isempty(τs) && return σ
    deg = max(degree(σ), maximum(degree, τs))
    img = Vector{inttype(σ)}(undef, deg)
    for i in Base.OneTo(deg)
        j = (i^σ)
        for τ in τs
            j = j^τ
        end
        @inbounds img[i] = j
    end
    return typeof(σ)(img, false)
end

function Base.:^(σ::AbstractPermutation, τ::AbstractPermutation)
    deg = max(degree(σ), degree(τ))
    img = Vector{inttype(σ)}(undef, deg)
    for i in Base.OneTo(deg)
        img[i^τ] = (i^σ)^τ
    end
    P = typeof(σ)
    return P(img, false)
end
