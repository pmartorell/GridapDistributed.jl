function all_tests(parts)
   display(parts)

   t = PArrays.PTimer(parts,verbose=true)
   PArrays.tic!(t)

   TestApp.GeometryTests.main(parts)
   PArrays.toc!(t,"Geometry")

   TestApp.CellDataTests.main(parts)
   PArrays.toc!(t,"CellData")

   TestApp.FESpacesTests.main(parts)
   PArrays.toc!(t,"FESpaces")

   TestApp.MultiFieldTests.main(parts)
   PArrays.toc!(t,"MultiField")

   TestApp.PoissonTests.main(parts)
   PArrays.toc!(t,"Poisson")

  TestApp.PLaplacianTests.main(parts)
  PArrays.toc!(t,"PLaplacian")

  TestApp.PeriodicBCsTests.main(parts)
  PArrays.toc!(t,"PeriodicBCs")

  TestApp.SurfaceCouplingTests.main(parts)
  PArrays.toc!(t,"SurfaceCoupling")

  display(t)
end
