module AbstractPermutations

import GroupsCore
import GroupsCore: GroupElement, order, InterfaceNotImplemented # only these two are extended

include("abstract_perm.jl")
include("cycle_decomposition.jl")
include("io.jl")
include("arithmetic.jl")
include("perm_functionality.jl")
include("parsing.jl")

end
