module GridapDistributed

using Gridap
using Gridap.Helpers
using Gridap.Geometry

export SequentialCommunicator

include("Communicators.jl")

include("ScatteredVectors.jl")

include("GhostedVectors.jl")

include("DistributedDiscreteModels.jl")

include("CartesianDiscreteModels.jl")

end # module
