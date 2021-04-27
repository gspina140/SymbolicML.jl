using SymbolicML

using Test

@testset "SymbolicML.jl" begin
    # Write your tests here.
    # Test Array
    x = [1, 2, -3]

    @test abs_energy(x) == 14

    @test absolute_maximum(x) == 3

    @test absolute_sum_of_changes(x) == 6

    d = Dict("f_agg" => "mean", "maxlag" => 1)
    @test agg_autocorrelation(x, d) = -0.2857142857142857
end
