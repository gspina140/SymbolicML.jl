include("dataset/loader.jl") # caricatore di dataset, o lettura di datasets
include("dataset/summary.jl") # descrizione del dataset per intero, oppure per istanze
include("dataset/transformation.jl") # trasformazione del dataset; e.g., differenze finite (cioè derivate discrete)
include("dataset/writer.jl") # scrivere sul file un dataset in formato csv o un formato che ci inveteremo

abstract type AbstractDataset end

abstract type AbstractSupervisedDataset <: AbstractDataset end
abstract type AbstractUnsupervisedDataset <: AbstractDataset end

abstract type AbstractClassificationDataset <: AbstractSupervisedDataset end
abstract type AbstractRegressionDataset <: AbstractSupervisedDataset end

struct ClassificationDataset <: AbstractClassificationDataset
    df::DataFrame
end

# julia> ex2 = CSV.read("/home/edu/.julia/dev/SymbolicML/data/Example_2.csv", DataFrame)

dataPath = "/home/edu/.julia/dev/SymbolicML/data/"
siemensDataInfo = CSV.read(joinpath(dataPath, "DataInfo.csv"), DataFrame)

df = DataFrame(values=DataFrame[], source=Int64[], day=Int64[], class=Int64[])
for i in 1:313
    ex = CSV.read(joinpath(dataPath, "Example_" * string(i) * ".csv"), DataFrame)
    push!(df, [ex, siemensDataInfo[i, :Datasource], siemensDataInfo[i, :Day], siemensDataInfo[i,:Class]])
end

siemensData = ClassificationDataset(df)

function select_attributes!(ds::ClassificationDataset, args...)
    for row in 1:nrow(ds.df)
        select!(ds.df[row,:values], args...)
    end
end

bestAttributes = [1,2,4,5,9,19,22,28,29,30]
