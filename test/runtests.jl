using SymbolicML
using Test

@testset "SymbolicML.jl" begin
    # Write your tests here.
    x = [-3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0]
    dd = discrete_derivatives(x; d=1)
    @test dd[:,1] == x
    @test dd[:,2] == [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0]
end
