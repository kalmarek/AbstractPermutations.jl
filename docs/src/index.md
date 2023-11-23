```@meta
CurrentModule = AbstractPermutations
```

# AbstractPermutations

The package defines an interface for abstract permutations.
The general assumptions are as follows:
We consider `AbstractPermutations` as bijective self-maps of
``\mathbb{N} = \{1,2,\ldots\}``, i.e. the **positive integers** which are
**finitely supported**. That means that for every permutation
``\sigma \colon \mathbb{N} \to \mathbb{N}`` there are only finitely many
``k\in \mathbb{N}`` such that the value of ``\sigma`` at ``k`` is different
from ``k``.

In practical terms this means that each permutation can be uniquely determined
by inspecting a vector of it's values on set ``\{1, 2, \ldots, n\}`` for some
``n``. By standard mathematical convention we will denote **the image** of
``k`` under ``\sigma`` by ``k^{\sigma}``, to signify that the set of bijections
_acts_ on ``\mathbb{N}``
[**on the right**](https://en.wikipedia.org/wiki/Group_action#Right_group_action).

For the description of the julia interface see the next section.
