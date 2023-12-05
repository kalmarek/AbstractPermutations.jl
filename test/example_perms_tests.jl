@testset "ExamplePerms" begin
    abstract_perm_interface_test(EP.Perm)

    p = EP.Perm([1]) # ()
    a = EP.Perm([2, 1, 3]) # (1,2)
    b = EP.Perm([2, 3, 1]) # (1,2,3)
    c = EP.Perm([1, 2, 3, 5, 4]) # (4,5)

    @test contains(sprint(show, MIME"text/plain"(), p), "()")
    @test contains(sprint(show, MIME"text/plain"(), a), "(1,2)")
    @test contains(sprint(show, MIME"text/plain"(), b), "(1,2,3)")
    @test contains(sprint(show, MIME"text/plain"(), c), "(4,5)")
    @test contains(sprint(show, MIME"text/plain"(), b * c), "(1,2,3)(4,5)")

    @testset "optimized definitions for *" begin
        replstr(x) = sprint(
            (io, x) -> show(
                IOContext(io, :limit => true, :displaysize => (10, 80)),
                MIME("text/plain"),
                x,
            ),
            x,
        )
        showstr(x) = sprint(
            (io, x) -> show(
                IOContext(io, :limit => true, :displaysize => (10, 80)),
                x,
            ),
            x,
        )

        showstr_nolimit(x) = sprint(
            (io, x) -> show(IOContext(io, :displaysize => (10, 80)), x),
            x,
        )

        @testset "seed = $seed" for seed in [1, 2, 3, 4]
            Random.seed!(seed)
            p = EP.Perm(Random.randperm(64))
            q = EP.Perm(Random.randperm(128))
            r = EP.Perm(Random.randperm(1256))

            @test replstr(r) isa String
            @test contains(replstr(r), "[output truncated]")
            @test contains(replstr(r), "…")

            @test showstr(r) isa String
            @test !contains(showstr(r), "[output truncated]")
            @test contains(showstr(r), "…")

            @test showstr_nolimit(r) isa String
            @test !contains(showstr_nolimit(r), "[output truncated]")
            @test !contains(showstr_nolimit(r), "…")

            @test p * q isa EP.Perm
            @test isperm((p * q).images)
            @test p * q == EP.Perm([(i^p)^q for i in 1:128])

            @test q * p isa EP.Perm
            @test isperm((q * p).images)
            @test q * p == EP.Perm([(i^q)^p for i in 1:128])

            @test p * q * r == p * (q * r)
            @test p * r * q == p * (r * q)
            @test r * p * q == r * (p * q)

            @test q * p * r == q * (p * r)
            @test q * r * p == q * (r * p)
            @test r * q * p == r * (q * p)

            @test p * q * q * p == (p * q) * (q * p)
            @test p * q * r * p == (p * q) * (r * p)
        end
    end
end