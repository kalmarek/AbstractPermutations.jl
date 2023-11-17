function _parse_cycles(str::AbstractString)
    cycles = Vector{Vector{Int}}()
    if occursin(r"\d\s+\d", str)
        throw(ArgumentError("parse string as cycles: spaces between digits"))
    end
    str = replace(str, r"\s+" => "")
    str = replace(str, "()" => "")
    cycle_regex = r"\(\d+(,\d+)*\)?"
    parsed_size = 0
    for m in eachmatch(cycle_regex, str)
        cycle_str = m.match
        parsed_size += sizeof(cycle_str)
        cycle = [parse(Int, a) for a in split(cycle_str[2:end-1], ",")]
        push!(cycles, cycle)
    end
    if parsed_size != sizeof(str)
        throw(
            ArgumentError(
                "parse string as cycles: parsed size differs from string",
            ),
        )
    end
    return cycles
end

function Base.parse(
    ::Type{P},
    str::AbstractString,
) where {P<:AbstractPermutation}
    cycles = _parse_cycles(str)
    deg = mapreduce(
        c -> length(c) > 1 ? maximum(c) : convert(eltype(c), (1)),
        max,
        cycles;
        init = 1,
    )
    images = Vector{inttype(P)}(undef, deg)
    for idx in Base.OneTo(deg)
        k = idx
        for cycle in cycles
            length(cycle) == 1 && continue
            i = findfirst(==(k), cycle)
            k = isnothing(i) ? k : cycle[mod1(i + 1, length(cycle))]
        end
        images[idx] = k
    end
    return P(images)
end

"""
    @perm P cycles_string
Macro to parse cycles decomposition as a string into a permutation of type `P`.

Strings for the output of e.g. GAP could be copied directly into `@perm`, as long as
they are not elided. Cycles of length `1` are not necessary, but can be included.

# Examples:
```julia
julia> p = @perm Perm{UInt16} "(1,3)(2,4)"
(1,3)(2,4)

julia> typeof(p)
Perm{UInt16}

julia> q = @perm Perm "(1,3)(2,4)(3,5)(8)"
(1,5,3)(2,4)

```
"""
macro perm(type, str)
    return :(Base.parse($(esc(type)), $str))
end
