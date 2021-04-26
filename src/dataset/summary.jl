# Absolute energy of the time series, the sum over the squared values
abs_energy(x) = mapreduce(x -> x * x, +, x) #use reduce(map()) is faster but with more mem allocation 
