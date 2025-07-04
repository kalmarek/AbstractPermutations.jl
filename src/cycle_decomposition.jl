struct CycleDecomposition{T<:Integer}
    cycles::Vector{T} # cycles, concatenated
    cycles_ptrs::Vector{T} # pointers to the starts of the cycles
end

degree(cd::CycleDecomposition) = length(cd.cycles)

Base.length(cd::CycleDecomposition) = length(cd.cycles_ptrs) - 1
function Base.eltype(::Type{CycleDecomposition{T}}) where {T}
    return SubArray{T,1,Vector{T},Tuple{UnitRange{Int64}},true}
end

function Base.iterate(cd::CycleDecomposition, state = 1)
    state == length(cd.cycles_ptrs) && return nothing
    from = cd.cycles_ptrs[state]
    to = cd.cycles_ptrs[state+1] - 1
    return @inbounds @view(cd.cycles[from:to]), state + 1
end

function Base.show(io::IO, cd::CycleDecomposition)
    print(io, "Cycle Decomposition: ")
    for c in cd
        print(io, '(')
        join(io, c, ',')
        print(io, ')')
    end
end

function CycleDecomposition(σ::AbstractPermutation)
    T = inttype(σ)
    deg = degree(σ)

    # allocate vectors of the expected size
    cycles = Vector{T}(undef, deg)
    visited = falses(deg)
    # the upper bound for the number of cycles
    cyclesptr = zeros(T, deg + 1)

    cptr_idx = 1
    cidx = 0
    cyclesptr[cptr_idx] = cidx + 1

    let ^ = __unsafe_image
        for idx in Base.OneTo(deg)
            @inbounds visited[idx] && continue
            first_pt = idx
            cidx += 1

            @inbounds cycles[cidx] = first_pt
            @inbounds visited[first_pt] = true
            next_pt = first_pt^σ
            while next_pt ≠ first_pt
                cidx += 1
                @inbounds cycles[cidx] = next_pt
                @inbounds visited[next_pt] = true
                next_pt = next_pt^σ
            end
            cptr_idx += 1 # we finished the cycle
            @inbounds cyclesptr[cptr_idx] = cidx + 1
        end
    end
    resize!(cycles, cidx)
    resize!(cyclesptr, cptr_idx)
    return CycleDecomposition{T}(cycles, cyclesptr)
end

"""
    getindex(v::AbstractArray, cycledec::CycleDecomposition)
Permute array `v`, according to the permutation represented by `cycledec`.

Permutations can be applied to any `1`-based array such that that `length(v) ≥ degree(p)`.
"""
function Base.getindex(v::AbstractArray, cycledec::CycleDecomposition)
    return permute!(copy(v), cycledec)
end

"""
    permute!(v::AbstractArray, cycledec::CycleDecomposition)
Permute array `v` in-place, according to the permutation represented by `cycledec`.

Permutations can be applied to any `1`-based array such that that `length(v) ≥ degree(p)`.
"""
function Base.permute!(v::AbstractArray, cycledec::CycleDecomposition)
    Base.require_one_based_indexing(v)
    if degree(cycledec) > length(v)
        throw(
            ArgumentError(
                "Cannot permute: Permutation degree is larger than array length",
            ),
        )
    end
    for c in cycledec
        length_c = length(c)
        @inbounds if length_c > 1
            temp = v[c[1]]
            for i in 1:(length_c-1)
                v[c[i]] = v[c[i+1]]
            end
            v[c[length_c]] = temp
        end
    end
    return v
end
