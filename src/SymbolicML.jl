module SymbolicML

using CSV
using DataFrames
using Plots
using StatsPlots

include("dataset.jl")

export discrete_derivative, discrete_derivatives
export ClassificationDataset
export siemensDataInfo, siemensData
export select_attributes

end
