struct ModalInstance <: AbstractVector{SubDataFrame}
    # worlds::Set{<:AbstractOntology} # TODO add set of worlds, for the semantics (RBC)
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

mutable struct ModalFrame <: AbstractVector{SubDataFrame}
    # name::String # TODO add name?
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

instance(cs::ClassificationDataset, i::Int) = cs.instances[i] # TODO cs -> ds (either sup or unsupervised)
instance(cs::ClassificationDataset, i::Int, f::Int) = cs.instances[i][f]
function attributes(ds::ClassificationDataset)
    d = Dict{Int,Array{String,1}}()
    for (fid,frame) in enumerate(ds.frames)
        d[fid] = names(frame.data)
    end
    return d
end
attributes(ds::ClassificationDataset, fid::Int) = names(ds.frames[fid].data)

function Base.show(io::IO, ::MIME"text/plain", ds::ClassificationDataset)
    println(io, "Classification dataset with $(length(ds.instances)) instances")

    for (i, inst) in enumerate(ds.instances)
        println(io, "Instance #$(i):")
        println(io, instance(ds, i))
        println(io)
    end
end

# TODO
# possible test: all([auslan.instances[i].rows[1][attr] === auslan.frames[1].data[i,attr] for i in 1:length(auslan.instances) for attr in attributes(auslan, 1)])
function transform!(ds::ClassificationDataset, f::Function, fid::Int; kwargs...)
    for attr in attributes(ds, fid)
        for i in 1:length(nrow(ds.frames[fid].data))
            ds.frames[fid].data[i,attr] = f(ds.frames[fid].data[i,attr]; kwargs...)
        end
    end
end

function select_attributes!(ds::ClassificationDataset, frame_attributes::Dict{Int, Array{Int, 1}})
    frames = collect(keys(frame_attributes))

    for i in 1:length(frames)
        ds.frames[frames[i]].data = ds.frames[frames[i]].data[:, frame_attributes[frames[i]]]
    end
end

function resample(ds::ClassificationDataset, percentage::Real,
                seed::Int; balanced::Bool = true)
    n_instances = length(ds.instances)
    sample_size = n_instances * percentage / 100

    Random.seed!(seed)

    selected = Array([i for i in 1:n_instances])

    for i in 1:sample_size
        chosenLoc = rand(1:n_instances)
        chosen    = selected[chosenLoc]
        n_instances -= 1
        selected[chosenLoc] = selected[n_instances]
        selected[n_instances] = chosen
    end

    train = DataFrame()
    test  = DataFrame()
    train_classes = Int[]
    test_classes  = Int[]

    attributes = names(ds.frames[1].data)

    for attr in attributes
        insertcols!(train, attr => Array{Float64, 1}[])
        insertcols!(test, attr => Array{Float64, 1}[])
    end

    for i in 1:length(selected)
        if i > n_instances
            push!(train, ds.frames[1].data[selected[i], :])
            push!(train_classes, ds.classes[selected[i]])
        else
            push!(test, ds.frames[1].data[selected[i], :])
            push!(test_classes, ds.classes[selected[i]])
        end
    end

    train_ds = ClassificationDataset([ModalFrame(train)], CategoricalArray(train_classes))
    test_ds  = ClassificationDataset([ModalFrame(test)], CategoricalArray(test_classes))

    if balanced == true
        train_ds = down_sample(train_ds, seed)
        test_ds = down_sample(test_ds, seed)
    end
    return train_ds, test_ds
end

function down_sample(ds::ClassificationDataset, seed::Int)
    Random.seed!(seed)

    balanced_df = DataFrame()
    classes = Int[]

    attributes = names(ds.frames[1].data)
    for attr in attributes
        insertcols!(balanced_df, attr => Array{Float64, 1}[])
    end

    trip_ind = Int[]
    shut_ind = Int[]

    for i in 1:length(ds.classes)
        if ds.classes[i] == 1
            push!(trip_ind, i)
        else
            push!(shut_ind, i)
        end
    end

    trips = length(trip_ind)
    shutdowns = length(shut_ind)

    if trips < shutdowns
        selected = Array([i for i in 1:shutdowns])
        #rem = shutdowns

        for i in 1:trips
            chosenLoc = rand(1:shutdowns)
            chosen = shut_ind[chosenLoc]
            shut_ind[chosenLoc] = shut_ind[shutdowns]
            shutdowns-=1
            selected[i] = chosen
            #selected[chosenLoc] = selected[shutdowns]
            #selected[shutdowns] = chosen
        end

        for i in 1:trips
            push!(balanced_df, ds.frames[1].data[trip_ind[i], :])
            push!(classes, ds.classes[trip_ind[i]])
            push!(balanced_df, ds.frames[1].data[selected[i], :])
            push!(classes, ds.classes[selected[i]])
        end
    else
        selected = Array([i for i in 1:trips])

        for i in 1:shutdowns
            chosenLoc = rand(1:trips)
            chosen = shut_ind[chosenLoc]
            shut_ind[chosenLoc] = shut_ind[trips]
            trips-=1
            selected[i] = chosen
            #selected[chosenLoc] = selected[trips]
            #selected[trips] = chosen
        end

        for i in 1:shutdowns
            push!(balanced_df, ds.frames[1].data[shut_ind[i], :])
            push!(classes, ds.classes[shut_ind[i]])
            push!(balanced_df, ds.frames[1].data[selected[i], :])
            push!(classes, ds.classes[selected[i]])
        end
    end

    return ClassificationDataset([ModalFrame(balanced_df)], CategoricalArray(classes))
end

# function transform!(ds::ClassificationDataset, f::Function; kwargs...)

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

"""

    if balanced == true
        #shutdowns = count(i -> i == 1, train_classes)
        #trips     = count(i -> i == 0, train_classes)

        ind_shut = Int[]
        ind_trip = Int[]
        #shutdowns = 1
        #trips = 1
        for i in 1:length(train_classes)
            if train_classes[i] == 1
                push!(ind_trip, i)
                #ind_shut[shutdowns] = i
                #shutdowns+=1
            else
                push!(ind_shut, i)
                #ind_trip[trips] = i
                #trips+=1
            end
        end

        shutdowns = length(ind_shut)
        trips = length(ind_trip)

        if shutdowns != trips
            if shutdowns < trips
                for i in 1:(trips-shutdowns)
                    chosen = rand(1:trips)
                    trips-=1
                    delete!(train, ind_trip[chosen])
                    splice!(train_classes, ind_trip[chosen])
                end
            else
                for i in 1:(shutdowns-trips)
                    chosen = rand(1:shutdowns)
                    shutdowns-=1
                    delete!(train, ind_shut[chosen])
                    splice!(train_classes, ind_shut[chosen])
                end
            end
        end

        #shutdowns = count(i -> i == 1, test_classes)
        #trips     = count(i -> i == 0, test_classes)
        #shutdowns = 1
        #trips = 1

        ind_shut = Int[]
        ind_trip = Int[]
        for i in 1:length(test_classes)
            if test_classes[i] == 1
                push!(ind_trip, i)
                #ind_shut[shutdowns] = i
                #shutdowns+=1
            else
                push!(ind_shut, i)
                #ind_trip[trips] = i
                #trips+=1
            end
        end

        if shutdowns != trips
            if shutdowns < trips
                for i in 1:(trips-shutdowns)
                    chosen = rand(1:trips)
                    trips-=1
                    delete!(test, ind_trip[chosen])
                    splice!(test_classes, ind_trip[chosen])
                end
            else
                for i in 1:(shutdowns-trips)
                    chosen = rand(1:shutdowns)
                    shutdowns-=1
                    delete!(train, ind_shut[chosen])
                    splice!(test_classes, ind_shut[chosen])
                end
            end
        end
    end
"""
