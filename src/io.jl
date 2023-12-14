# IO

function Base.show(io::IO, ::MIME"text/plain", g::AbstractPermutation)
    r, c = displaysize(io)
    ioc = IOContext(
        io,
        :available_width =>
            get(io, :limit, false) ? (r ÷ 2) * (c - 5) : typemax(Int),
    )
    k = __print_perm(ioc, g)
    if !iszero(k)
        print(ioc, '\n', lpad("[output truncated]", c - 5))
    end
end

function Base.show(io::IO, g::AbstractPermutation)
    _, c = displaysize(io)
    ioc = IOContext(
        io,
        :available_width => get(io, :limit, false) ? c - 5 : typemax(Int),
    )
    return __print_perm(ioc, g)
end

function __print_perm(io::IOContext, p::AbstractPermutation;)
    available_width = get(io, :available_width, typemax(Int))
    limit = get(io, :limit, false)
    if !(get(io, :typeinfo, Nothing) <: AbstractPermutation || limit)
        str = sprint(show, typeof(p))
        print(io, str, " ")
        available_width -= length(str) + 1
    end

    if isone(p)
        print(io, "()")
    else
        for (i, c) in enumerate(cycles(p))
            trunc, available_width = __print_cycle(io, c, available_width)
            trunc && return i
        end
    end
    return 0
end

function __print_cycle(io::IO, cycle, available_width)
    length(cycle) == 1 && return false, available_width

    str = join(cycle, ',')
    truncated = length(str) + 2 > available_width
    if truncated
        print(io, '(', SubString(str, 1, available_width - 5), " … )")
    else
        print(io, '(', str, ')')
    end
    return truncated, available_width - (length(str) + 2)
end
