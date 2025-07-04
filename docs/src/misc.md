```@meta
CurrentModule = AbstractPermutations
```

## Permutation specific functions

```@docs
isodd(::AbstractPermutation)
iseven(::AbstractPermutation)
sign(::AbstractPermutation)
permtype
cycles
Base.permute!(::AbstractArray, ::AbstractArray, ::AbstractPermutation)
Base.permute!(::AbstractArray, ::CycleDecomposition)
Lex
DegLex
```

## Function specific to actions on `1:n`

```@docs
firstmoved
fixedpoints
nfixedpoints
```

## The `@perm` macro

```@docs
@perm
```
