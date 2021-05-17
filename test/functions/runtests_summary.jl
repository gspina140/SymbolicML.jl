@testset "functions/summary.jl" begin
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

    @test c3(x,5) == 0.
    @test c3(x,4) == 0.
    @test c3(y,5) == 66.

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

    @test first_location_of_maximum(x) == 1
    @test first_location_of_maximum(y) == 1

    @test first_location_of_minimum(x) == 0.09090909090909091
    @test first_location_of_minimum(y) == 0.9090909090909091

    @test longest_strike_above_mean(x) == 5
    @test longest_strike_above_mean(y) == 5

    @test longest_strike_below_mean(x) == 5
    @test longest_strike_below_mean(y) == 4

    @test has_duplicate(x) == false
    @test has_duplicate(y) == false

    @test has_duplicate_max(x) == false
    @test has_duplicate_max(y) == false

    @test has_duplicate_min(x) == false
    @test has_duplicate_min(y) == false

    @test large_standard_deviation(x, 2.) == false
    @test large_standard_deviation(y, 2.) == false

    @test last_location_of_maximum(x) == 0.09090909090909091
    @test last_location_of_maximum(y) == 0.09090909090909091

    @test last_location_of_minimum(x) == 1
    @test last_location_of_minimum(y) == 0.18181818181818182

    @test mean_abs_change(x) == 1.0
    @test mean_abs_change(y) == 4.8

    @test mean_change(x) == 1.
    @test mean_change(y) == 1.

    @test mean_n_absolute_max(x, 3) == 4.666666666666667
    @test mean_n_absolute_max(y, 2) == 10.5

    @test mean_second_derivative_central(x) == 0.5555555555555556
    @test mean_second_derivative_central(y) == 1.0

    @test number_crossing_m(x, 2.0) == 1
    @test number_crossing_m(y, 7.0) == 3

    # @test percentage_of_reoccurring_datapoints_to_all_datapoints(x) == 0.0
    # @test percentage_of_reoccurring_datapoints_to_all_datapoints(y) == 0.0
    #
    # @test percentage_of_reoccurring_values_to_all_values(x) == 0.0
    # @test percentage_of_reoccurring_values_to_all_values(y) == 0.0

    @test range_count(x, 0., 2.) == 2
    @test range_count(y, 6., 9.) == 3

    @test ratio_beyond_r_sigma(x, 1.) == 1.6363636363636365
    @test ratio_beyond_r_sigma(y, 2.) == 1.2892561983471074

    # @test ratio_value_number_to_time_series_length(x) == 1.
    # @test ratio_value_number_to_time_series_length(y) == 1.

    @test root_mean_square(x) == 3.1622776601683795
    @test root_mean_square(y) == 6.782329983125268

#   @test sample_entropy(x) == NaN != NaN ...
    @test sample_entropy(y) == 0.11778303565638351

    # @test sum_of_reoccurring_data_points(x) == 0
    # @test sum_of_reoccurring_data_points(y) == 0

end
