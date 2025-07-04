function Base.inv(σ::AbstractPermutation)
    img = Vector{inttype(σ)}(undef, degree(σ))
    let ^ = __unsafe_image
        for i in Base.OneTo(degree(σ))
            k = i^σ
            @inbounds img[k] = i
        end
    end
    return typeof(σ)(img; check = false)
end

function Base.:(*)(σ::AbstractPermutation, τ::AbstractPermutation)
    img = Vector{inttype(σ)}(undef, max(degree(σ), degree(τ)))
    let ^ = __unsafe_image
        if degree(σ) ≤ degree(τ)
            for i in Base.OneTo(degree(σ))
                k = (i^σ)^τ
                @inbounds img[i] = k
            end
            for i in (degree(σ)+1):degree(τ)
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
    return typeof(σ)(img; check = false)
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
            for i in (degσ+1):degτ
                k = (i^τ)^ρ
                @inbounds img[i] = k
            end
            for i in (degτ+1):degρ
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
            for i in (degσ+1):degρ
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
    return typeof(σ)(img; check = false)
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
    return typeof(σ)(img; check = false)
end

function Base.:^(σ::AbstractPermutation, τ::AbstractPermutation)
    deg = max(degree(σ), degree(τ))
    img = Vector{inttype(σ)}(undef, deg)
    for i in Base.OneTo(deg)
        img[i^τ] = (i^σ)^τ
    end
    P = typeof(σ)
    return P(img; check = false)
end

function Base.:^(σ::AbstractPermutation, n::Integer)
    if n == 0 || isone(σ)
        return one(σ)
    elseif n == -1
        return inv(σ)
    elseif n == 1
        return copy(σ)
    elseif n < 0
        return inv(σ)^-n
    elseif n == 2
        return σ * σ
    elseif n == 3
        return σ * σ * σ
    elseif n == 4
        σ² = σ * σ
        return σ² * σ²
    elseif n == 5
        σ² = σ * σ
        return σ² * σ² * σ
    elseif n == 6
        σ³ = σ * σ * σ
        return σ³ * σ³
    elseif n == 7
        σ³ = σ * σ * σ
        return σ³ * σ³ * σ
    elseif n == 8
        σ² = σ * σ
        σ⁴ = σ² * σ²
        return σ⁴ * σ⁴
    elseif degree(σ) ≤ 64 || 2count_ones(n) > log2(degree(σ))
        power_by_cycles(σ, n)
    else
        Base.power_by_squaring(σ, n)
    end
end

function power_by_cycles(σ::AbstractPermutation, n::Integer)
    if n == 0 || isone(σ)
        return one(σ)
    elseif n == -1
        return inv(σ)
    elseif n == 1
        return copy(σ)
    elseif n < 0
        return power_by_cycles(inv(σ), -n)
    else
        img = Vector{inttype(σ)}(undef, degree(σ))
        @inbounds for cycle in cycles(σ)
            l = length(cycle)
            k = n % l
            for (idx, j) in enumerate(cycle)
                idx += k
                idx = ifelse(idx > l, idx - l, idx)
                img[j] = cycle[idx]
            end
        end
        return typeof(σ)(img; check = false)
    end
end
