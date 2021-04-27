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
