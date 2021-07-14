# DateDataFrames

[![Build Status](https://github.com/yiyuezhuo/DateDataFrames.jl/workflows/CI/badge.svg)](https://github.com/yiyuezhuo/DateDataFrames.jl/actions)

[TimeSeries.jl](https://github.com/JuliaStats/TimeSeries.jl) has many drawbacks to me, for example:

* Data is stored in a matrix.
* Hard to modify data.
* Time stamp is stored as a (ordered) dense DateTime vector.
* Many meaningless copying.
* O(log(N)) datetime indexing access. (based on `searchsorted`)

To be honest, I can't see many benefits on the design. Maybe some true "Time Series" modelers will appreciate the matrix, but I just want a first class timestamp index.

Instead, this package provides a simple wrapper based on [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl). You can just detach the DataFrame object when you done all the work related to timestamp.

The package will try to clone `TimeSeries` API such as `TimeArray` and `diff` since some my personal projects are using `TimeSeries`. 

```julia

```
