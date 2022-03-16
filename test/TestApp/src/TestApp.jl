module TestApp
  include("../../CellDataTests.jl")
  include("../../FESpacesTests.jl")
  include("../../GeometryTests.jl")
  include("../../MultiFieldTests.jl")
  include("../../PLaplacianTests.jl")
  include("../../PoissonTests.jl")
  include("../../PeriodicBCsTests.jl")
  include("../../TransientDistributedCellFieldTests.jl")
  include("../../TransientMultiFieldDistributedCellFieldTests.jl")
  include("../../HeatEquationTests.jl")
  include("../../StokesOpenBoundaryTests.jl")
end
