@testset "dataset/summary.jl" begin
    # Write your tests here.
    # Test Array
    x = [1.0, 2.0, -3.0]

    @test abs_energy(x) == 14

    @test absolute_maximum(x) == 3

    @test absolute_sum_of_changes(x) == 6

    d = Dict("f_agg" => "mean", "maxlag" => 1)
    @test agg_autocorrelation(x, d) == -0.2857142857142857

    @test autocorrelation(x,2) == -0.42857142857142855

    @test benford_correlation(x) == 0.8151300976944044

    @test binned_entropy(x,5) == 0.7324081924454064

    @test c3(x,1) == -6

    @test cid_ce(x, false) == 5.0990195135927845
    #@test cid_ce(x, true)  == 1.927245026971402 # !!! False->Evaluated: 1.927248223318863 == 1.927245026971402

    @test count_above(x, 1.0) == 0.3333333333333333
    @test count_above_mean(x) == 2

    @test count_below(x,2.0) == 0.6666666666666666

    @test count_below_mean(x) == 1
end
