include("dataset/loader.jl") # caricatore di dataset, o lettura di datasets
# include("dataset/summary.jl") # descrizione del dataset per intero, oppure per istanze
include("dataset/transformation.jl") # trasformazione del dataset; e.g., differenze finite (cioè derivate discrete)
include("dataset/writer.jl") # scrivere sul file un dataset in formato csv o un formato che ci inveteremo

abstract type AbstractDataset end

abstract type AbstractSupervisedDataset <: AbstractDataset end
abstract type AbstractUnsupervisedDataset <: AbstractDataset end

abstract type AbstractClassificationDataset <: AbstractSupervisedDataset end
abstract type AbstractRegressionDataset <: AbstractSupervisedDataset end

# struct ClassificationDataset <: AbstractClassificationDataset
#     df::DataFrame
# end
#
# # julia> ex2 = CSV.read("/home/edu/.julia/dev/SymbolicML/data/Example_2.csv", DataFrame)
#
# dataPath = "/home/edu/.julia/dev/SymbolicML/data/"
# siemensDataInfo = CSV.read(joinpath(dataPath, "DataInfo.csv"), DataFrame)
#
# df = DataFrame(values=DataFrame[], source=Int64[], day=Int64[], class=Int64[])
# for i in 1:313
#     ex = CSV.read(joinpath(dataPath, "Example_" * string(i) * ".csv"), DataFrame)
#     push!(df, [ex, siemensDataInfo[i, :Datasource], siemensDataInfo[i, :Day], siemensDataInfo[i,:Class]])
# end
#
# siemensData = ClassificationDataset(df)
#
# function select_attributes!(ds::ClassificationDataset, args...)
#     for row in 1:nrow(ds.df)
#         select!(ds.df[row,:values], args...)
#     end
# end
#
# bestAttributes = [1,2,4,5,9,19,22,28,29,30]

struct ClassificationDataset # <: AbstractClassificationDataset
    data::DataFrame
    frame_attributes::Dict{String,Array{String, 1}}
    frames::Array{String, 1} # keys(attributes) << NO!
    # function ClassificationDataset(df::DataFrame) =
    #     data = df
    #     frames = names(df)[1:end-1] # Assumption: class is the last variable
    # end
end

struct DS
    df::DataFrame
end

function DS(v::AbstractArray{T,1}) where T<:AbstractArray{S,2} where S<:Real
    _, n_attr = size(v[1])
    df = DataFrame(Timeseries=DataFrame[])
    ts = DataFrame()

    for i in 1:n_attr
        insertcols!(ts, Symbol("x" * "$i") => AbstractArray{Float64, 1})
    end
    # @show n_attr
    if length(v) > 1
        for i in 2:length(v)
            _, curr_n_attr = size(v[i])
            # @show curr_n_attr
            if n_attr ≠ curr_n_attr
                error("Each time series must have the same number of attributes!")
            end
        end
    end
    DS(df)
end

frames(d::ClassificationDataset) = d.frames

df = DataFrame(Images=DataFrame[], Timeseries=DataFrame[], class=String[])
# F1 = DataFrame(A1=Array{Float64,2}[], A2=Array{Float64,2}[])
# A = [1.1 2.1 3.1; 4.1 5.1 6.1]
# B = [1.2 2.2 3.2; 4.2 5.2 6.2]
# push!(F1, [A, B])
# F2 = DataFrame(B1=Array{Float64,2}[], B2=Array{Float64,2}[])
# C = [1.3 2.3 3.3; 4.3 5.3 6.3]
# D = [1.4 2.4 3.4; 4.4 5.4 6.4]
# push!(F2, [C, D])
# push!(df, [F1_1, F2_1, "0"])

# Images frame
Images = DataFrame(Red=Array{Float64,2}[], Green=Array{Float64,2}[], Blue=Array{Float64,2}[])
# image frame (1st instance)
# 3x2 pixels 3 channels
Img1 = Array{Float64}(undef, 3, 2, 3)
# red channel
Img1[:,1,1] = [11. 21. 31.]
Img1[:,2,1] = [41. 51. 61.]
# green channel
Img1[:,1,2] = [12. 22. 32.]
Img1[:,2,2] = [42. 52. 62.]
# blue channel
Img1[:,1,3] = [13. 23. 33.]
Img1[:,2,3] = [43. 53. 63.]
# image frame (2nd instance, with different size)
# 3x3 pixels 3 channels
Img2 = Array{Float64}(undef, 3, 3, 3)
# red channel
Img2[:,1,1] = [11. 21. 31.]
Img2[:,2,1] = [41. 51. 61.]
Img2[:,3,1] = [71. 81. 91.]
# green channel
Img2[:,1,2] = [12. 22. 32.]
Img2[:,2,2] = [42. 52. 62.]
Img2[:,3,2] = [72. 82. 92.]
# blue channel
Img2[:,1,3] = [13. 23. 33.]
Img2[:,2,3] = [43. 53. 63.]
Img2[:,3,3] = [73. 83. 93.]
# push both instances
push!(Images, [Img1[:,:,i] for i in 1:3])
push!(Images, [Img2[:,:,i] for i in 1:3])

# Timeseries frame
Timeseries = DataFrame(Temperature=Array{Float64,1}[], Fever=Array{Float64,1}[])
# timeseries frame (1st instance)
# 3-points 2 variables
Ts1 = Array{Float64}(undef, 3, 2)
Ts1[:,1] = [11. 21. 31.]
Ts1[:,2] = [41. 51. 61.]
# timeseries frame (2nd instance)
# 4-points 2 variables
Ts2 = Array{Float64}(undef, 4, 2)
Ts2[:,1] = [12. 22. 32. 42.]
Ts2[:,2] = [52. 62. 72. 82.]
# push both instances
push!(Timeseries, [Ts1[:,i] for i in 1:2])
push!(Timeseries, [Ts2[:,i] for i in 1:2])

# push to bigger dataframe
push!(df, [Images, Timeseries, "0"])
