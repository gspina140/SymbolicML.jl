function trip_shutdown(path::String, day::Int) # day = 4 solo 4th, day = 1 tutti
    df = DataFrame()
    classes = Int[]
    attributes = CSV.File(path * "/Example_1.csv", drop = [1, 2]) |> DataFrame |> names

    for attr in attributes
        insertcols!(df, attr => Array{Float64, 1}[])
    end

    for row in CSV.File(path * "/DataInfo.csv")
        if row.Day >= day
            aux = CSV.File(path * "/Example_" * string(row.ExampleID) * ".csv", drop = [1, 2]) |> Tables.matrix

            push!(df, [aux[:, j] for j in 1:length(attributes)])

            push!(classes, row.Class)
        end
    end

    ds = ClassificationDataset([ModalFrame(df)], CategoricalArray(classes))

    return ds
end


function trip_no_trip(path::String; n_machine::Union{Missing, Int64} = missing)
    df = DataFrame()
    classes = Int[]
    attributes = CSV.File(path * "/Example_1.csv", drop = [1, 2]) |> DataFrame |> names

    for attr in attributes
        insertcols!(df, attr => Array{Float64, 1}[])
    end

    for row in CSV.File(path * "/DataInfo.csv")
        if row.Class == 0
            continue
        else
            if !ismissing(n_machine) && row.Datasource != n_machine
                continue
            end

            aux = CSV.File(path * "/Example_" * string(row.ExampleID) * ".csv", drop = [1, 2]) |> Tables.matrix

            push!(df, [aux[:, j] for j in 1:length(attributes)])

            if row.Day < 4
                push!(classes, 0)
            else
                push!(classes, 1)
            end
        end
    end

    ds = ClassificationDataset([ModalFrame(df)], CategoricalArray(classes))

    return ds
end
