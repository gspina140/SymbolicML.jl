using SymbolicML

using Test

@testset "SymbolicML.jl" begin
    # Write your tests here.
    @test abs_energy([1,2,3]) == 14
end
