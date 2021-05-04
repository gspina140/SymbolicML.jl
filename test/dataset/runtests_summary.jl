@testset "dataset/summary.jl" begin
    # Write your tests here.
    # Test Array
    #x = [1.0, 2.0, -3.0]
    x=[-5.,-4.,-3.,-2.,-1.,0,1.,2.,3.,4.,5.]
    y=[1.,2.,3.,4.,5.,6.,7.,8.,9.,-10.,11.]

    @test abs_energy(x) == 110.
    @test abs_energy(y) == 506.

    @test absolute_maximum(x) == 5.
    @test absolute_maximum(y) == 11.

    @test absolute_sum_of_changes(x) == 10
    @test absolute_sum_of_changes(y) == 48

    @test agg_autocorrelation(x,"mean",2) == 0.6212121212121213#0.6213
    @test agg_autocorrelation(y,"mean",2) == -0.18300395256916996#-0.1825

    @test autocorrelation(x, 2) == 0.5151515151515152#0.5151
    @test autocorrelation(y,2) == 0.015546772068511216#0.0155

    @test benford_correlation(x) == 0.64055170771251
    @test benford_correlation(y) == 0.8641230464899805

    @test binned_entropy(y,3) == 0.3821755938143392
    @test binned_entropy(x,3) == 0.7167794185129729

    #@test c3(x,5) = 0.
    #@test c3(x,4) = 0.
    #@test c3(y,5) = 66.

    @test change_quantiles(x, 0., 1., "mean") == 0
    @test change_quantiles(y, 0., 1., "var") == 10.266666666666667

    @test cid_ce(x, true) == 0.9534625892455924
    @test cid_ce(y, false) == 28.460498941515414

    @test count_above(x, 4.) == 0.09090909090909091
    @test count_above(y, 3.) == 0.6363636363636364

    @test count_above_mean(x) == 5
    @test count_above_mean(y) == 6

    @test count_below(x, 0.) == 0.45454545454545453
    @test count_below(y, 1.) == 0.09090909090909091

    @test count_below_mean(x) == 5
    @test count_below_mean(y) == 5
end
