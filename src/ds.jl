struct ModalInstance <: AbstractVector{SubDataFrame}
    rows::Vector{DataFrameRow}
end

ModalInstance() = ModalInstance(DataFrameRow[])
DataFrames.nrow(::Array{DataFrameRow,1}) = 1

function Base.show(io::IO, ::MIME"text/plain", mi::ModalInstance)
    println(io, "Modal instance with $(length(mi.rows)) frames")
    for i in 1:length(mi.rows)
        println(io, "Frame #$i")
        println(io, mi.rows[i])
    end
end

Base.size(mi::ModalInstance) = (nrow(mi.rows),)
Base.getindex(mi::ModalInstance, i::Int) = mi.rows[i]

struct ModalFrame <: AbstractVector{SubDataFrame}
    dimension::Int  # (0=static, 1=timeseries, 2=images, ecc.)
    data::DataFrame
    views::Vector{DataFrameRow} # intraframe instances (i.e., first, second, .., series)
end

dimension(mf::ModalFrame) = mf.dimension

@inline function ModalFrame(data::DataFrame)
    colnames = names(data)

    @assert length(colnames) > 0 && nrow(data) > 0 "There must be at least one column and one instance in data to compute its dimension."

    dimension = ndims(data[1, Symbol(colnames[1])])

    for colname in colnames
        curr_dimension = ndims(data[1, Symbol(colname)])
        @assert dimension == curr_dimension "Each attribute must have the same dimension."
    end

    # if dimension > 0
    #     typ = eltype(data[1, Symbol(colnams[1])])
    #     for colname in colnames
    #         curr_typ = eltype(data[1, Symbol(colname)])
    #         @assert typ == cur_typ "Each modal frame with higher-than-zero dimension must have the same element types."
    #     end
    # end

    views = Vector{DataFrameRow}(undef, nrow(data))
    for i in 1:nrow(data)
        views[i] = view(data, i, :)
    end
    ModalFrame(dimension, data, views)
end

Base.size(mf::ModalFrame) = (nrow(mf.data),)
Base.getindex(mf::ModalFrame, i::Int) = mf.views[i]

struct ClassificationDataset
    ldim::Int
    hdim::Int
    frames::Vector{ModalFrame}
    instances::Vector{ModalInstance}
    classes::CategoricalArray
end

function ClassificationDataset(frames::Vector{ModalFrame}, classes::CategoricalArray)
    instances = ModalInstance[]

    n_instances = size(frames[1])

    for i in 1:length(frames)
        curr_n_instances = size(frames[i])
        @assert n_instances == curr_n_instances "Each frame must have the same number of (intraframe) instances!"
    end

    @assert n_instances[1] == length(classes) "Each instance must have one and only one class!"

    # for each instance
    for i in 1:n_instances[1]
        instance = ModalInstance()
        # for each frame
        for f in 1:length(frames)
            # push the instance
            push!(instance.rows, frames[f][i])
        end
        push!(instances, instance)
    end

    ldim, hdim = extrema([dimension(i) for i in frames])

    ClassificationDataset(ldim, hdim, frames, instances, classes)
end

instance(cs::ClassificationDataset, i::Int) = cs.instances[i]
instance(cs::ClassificationDataset, i::Int, f::Int) = cs.instances[i][f]

function Base.show(io::IO, ::MIME"text/plain", ds::ClassificationDataset)
    println(io, "Classification dataset with $(length(ds.instances)) instances")

    for (i, inst) in enumerate(ds.instances)
        println(io, "Instance #$(i):")
        println(io, instance(ds, i))
        println(io)
    end
end

using MultivariateTimeSeries
X, y = read_data_labeled(joinpath(dirname(pathof(GBDTs)), "..", "data", "auslan_youtube8"));

# adesso voglia passare da MTS a ClassificationDataset

my_frame = DataFrame()

for attr in names(X)
    insertcols!(my_frame, attr => Array{Float64,1}[])
end

# for each instance
for i in 1:length(X)
    array_data = Array{Float64, 2}(X[i])
    push!(my_frame, [array_data[:, j] for j in 1:length(names(X))])
end

auslan = ClassificationDataset([ModalFrame(my_frame)], CategoricalArray(y))


# julia> p = MonteCarlo(30, 5)
# julia> using Random; Random.seed!(1)
# julia> model = induce_tree(grammar, :b, p, auslan.frames[1], y, 6);
