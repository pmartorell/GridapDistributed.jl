module MultiFieldTests

using Gridap
using Gridap.FESpaces
using Gridap.MultiField
using GridapDistributed
using PartitionedArrays
using Test

function l2_error(u1,u2,dΩ)
  eu = u1 - u2
  sqrt(sum(∫( eu⋅eu )dΩ))
end

function main(distribute, parts, mfs)
  ranks  = distribute(LinearIndices((prod(parts),)))
  output = mkpath(joinpath(@__DIR__,"output"))

  domain = (0,4,0,4)
  cells = (4,4)
  model = CartesianDiscreteModel(ranks,parts,domain,cells)
  Ω = Triangulation(model)

  k = 2
  dΩ = Measure(Ω,2*k)
  reffe_u = ReferenceFE(lagrangian,VectorValue{2,Float64},k)
  reffe_p = ReferenceFE(lagrangian,Float64,k-1,space=:P)

  u((x,y)) = VectorValue((x+y)^2,(x-y)^2)
  p((x,y)) = x+y
  f(x) = - Δ(u,x) + ∇(p,x)
  g(x) = tr(∇(u,x))

  V = TestFESpace(model,reffe_u,dirichlet_tags="boundary")
  Q = TestFESpace(model,reffe_p,constraint=:zeromean)
  U = TrialFESpace(V,u)
  P = TrialFESpace(Q,p)

  VxQ = MultiFieldFESpace([V,Q];style=mfs)
  UxP = MultiFieldFESpace([U,P];style=mfs) # This generates again the global numbering
  UxP = TrialFESpace([u,p],VxQ) # This reuses the one computed
  @test length(UxP) == 2

  uh, ph = interpolate([u,p],UxP)
  @test l2_error(u,uh,dΩ) < 1.0e-9
  @test l2_error(p,ph,dΩ) < 1.0e-9

  a((u,p),(v,q)) = ∫( ∇(v)⊙∇(u) - q*(∇⋅u) - (∇⋅v)*p )*dΩ
  l((v,q)) = ∫( v⋅f - q*g )*dΩ

  op = AffineFEOperator(a,l,UxP,VxQ)
  if !isa(mfs,BlockMultiFieldStyle) # BlockMultiFieldStyle does not support BackslashSolver
    solver = LinearFESolver(BackslashSolver())
    uh, ph = solve(solver,op)
    @test l2_error(u,uh,dΩ) < 1.0e-9
    @test l2_error(p,ph,dΩ) < 1.0e-9

    writevtk(Ω,"Ω",nsubcells=10,cellfields=["uh"=>uh,"ph"=>ph])
  end

  A  = get_matrix(op)
  xh = interpolate([u,p],UxP)
  x  = GridapDistributed.change_ghost(get_free_dof_values(xh),axes(A,2))
  uh1, ph1 = FESpaces.EvaluationFunction(UxP,x)
  uh2, ph2 = FEFunction(UxP,x)

  @test l2_error(u,uh1,dΩ) < 1.0e-9
  @test l2_error(p,ph1,dΩ) < 1.0e-9
  @test l2_error(u,uh2,dΩ) < 1.0e-9
  @test l2_error(p,ph2,dΩ) < 1.0e-9

  a1(x,y) = ∫(x⋅y)dΩ
  a2((u,p),(v,q)) = ∫(u⋅v + p⋅q)dΩ
  A1 = assemble_matrix(a1,UxP,UxP)
  A2 = assemble_matrix(a2,UxP,UxP)

  x = prandn(partition(axes(A1,2)))
  @test norm(A1*x-A2*x) < 1.0e-9
end

function main(distribute, parts)
  main(distribute, parts, ConsecutiveMultiFieldStyle())
  main(distribute, parts, BlockMultiFieldStyle())
end

end # module
