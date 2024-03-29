module SymbolicML

using CSV
using DataFrames
using Plots
using StatsPlots

include("dataset.jl")
include("functions.jl")

export discrete_derivative, discrete_derivatives
export siemensDataInfo, siemensData

export select_attributes
export abs_energy
export absolute_maximum
export absolute_sum_of_changes
export agg_autocorrelation
export autocorrelation
export benford_correlation
export binned_entropy
export c3
export change_quantiles
export cid_ce
export count_above
export count_above_mean
export count_below
export count_below_mean
export first_location_of_maximum
export first_location_of_minimum
export has_duplicate
export has_duplicate_max
export has_duplicate_min
export large_standard_deviation
export last_location_of_maximum
export last_location_of_minimum
export mean_abs_change
export mean_change
export mean_n_absolute_max
export longest_strike_above_mean
export longest_strike_below_mean
export mean_second_derivative_central
export number_crossing_m
export percentage_of_reoccurring_datapoints_to_all_datapoints
export percentage_of_reoccurring_values_to_all_values
export range_count
export ratio_beyond_r_sigma
export ratio_value_number_to_time_series_length
export root_mean_square
export sample_entropy
export sum_of_reoccurring_data_points

end
