module CellDataTests

using Test

@testset "CellFields" begin include("CellFieldsTests.jl") end

@testset "CellQuadratures" begin include("CellQuadraturesTests.jl") end

@testset "DomainContributions" begin include("DomainContributionsTests.jl") end

@testset "CellDofsTests" begin include("CellDofsTests.jl") end

@testset "AttachDirichlet" begin include("AttachDirichletTests.jl") end

@testset "AttachConstraints" begin include("AttachConstraintsTests.jl") end

@testset "CellStates" begin include("QPointCellFieldsTests.jl") end

#
#@testset "QPointCellFields" begin include("QPointCellFieldsTests.jl") end
#
#@testset "CellDofBases" begin include("CellDofBasesTests.jl") end
#
#
#
#@testset "Law" begin include("LawTests.jl") end

end # module
