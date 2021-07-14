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
using DateDataFrames
using DataFrames
using MarketData

df = DataFrame(AAPL) # TimeArray -> DataFrame
df |> first |> println

#=
2×13 DataFrame
 Row │ timestamp   Open     High     Low      Close    Volume         ExDividend  SplitRatio  AdjOpen  AdjHigh  AdjLow   AdjClose  AdjVolume 
     │ Date        Float64  Float64  Float64  Float64  Float64        Float64     Float64     Float64  Float64  Float64  Float64   Float64   
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 1980-12-12    28.75    28.88    28.75    28.75       2.0939e6         0.0         1.0  3.37658  3.39185  3.37658   3.37658  1.67512e7
   2 │ 1980-12-15    27.38    27.38    27.25    27.25  785200.0              0.0         1.0  3.21568  3.21568  3.20041   3.20041  6.2816e6
=#

ddf = DateDataFrame(DateTime.(df.timestamp), df[!, 2:end])
ddf[1:2, :]

#=
DateDataFrame: time::Vector{DateTime} span=> 1980-12-12T00:00:00->1980-12-15T00:00:00 extended df=2×13 DataFrame
 Row │ __date               Open     High     Low      Close    Volume         ⋯
     │ DateTime             Float64  Float64  Float64  Float64  Float64        ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 1980-12-12T00:00:00    28.75    28.88    28.75    28.75       2.0939e6  ⋯
   2 │ 1980-12-15T00:00:00    27.38    27.38    27.25    27.25  785200.0
=#

ddf[DateTime(1980, 12, 12), :Open] = 100
ddf[1:2, :]

#=
DateDataFrame: time::Vector{DateTime} span=> 1980-12-12T00:00:00->1980-12-15T00:00:00 extended df=2×13 DataFrame
 Row │ __date               Open     High     Low      Close    Volume         ⋯
     │ DateTime             Float64  Float64  Float64  Float64  Float64        ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 1980-12-12T00:00:00   100.0     28.88    28.75    28.75       2.0939e6  ⋯
   2 │ 1980-12-15T00:00:00    27.38    27.38    27.25    27.25  785200.0
=#

df[1:2, :] |> println
#=
2×13 DataFrame
 Row │ timestamp   Open     High     Low      Close    Volume         ExDividend  SplitRatio  AdjOpen  AdjHigh  AdjLow   AdjClose  AdjVolume 
     │ Date        Float64  Float64  Float64  Float64  Float64        Float64     Float64     Float64  Float64  Float64  Float64   Float64   
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 1980-12-12   100.0     28.88    28.75    28.75       2.0939e6         0.0         1.0  3.37658  3.39185  3.37658   3.37658  1.67512e7
   2 │ 1980-12-15    27.38    27.38    27.25    27.25  785200.0              0.0         1.0  3.21568  3.21568  3.20041   3.20041  6.2816e6
=#

ddf2 = resample(Nearest(), ddf, Day(1))
#=
DateDataFrame: time::StepRange{DateTime, Day} span=> 1980-12-12T00:00:00->2013-12-31T00:00:00 extended df=12073×13 DataFrame
   Row │ __date               Open     High     Low      Close    Volume       ⋯
       │ DateTime             Float64  Float64  Float64  Float64  Float64      ⋯
───────┼────────────────────────────────────────────────────────────────────────
     1 │ 1980-12-12T00:00:00   100.0     28.88    28.75    28.75       2.0939e ⋯
     2 │ 1980-12-13T00:00:00   100.0     28.88    28.75    28.75       2.0939e
     3 │ 1980-12-14T00:00:00    27.38    27.38    27.25    27.25  785200.0
     4 │ 1980-12-15T00:00:00    27.38    27.38    27.25    27.25  785200.0
     5 │ 1980-12-16T00:00:00    25.38    25.38    25.25    25.25  472000.0     ⋯
     6 │ 1980-12-17T00:00:00    25.88    26.0     25.88    25.88  385900.0
     7 │ 1980-12-18T00:00:00    26.62    26.75    26.62    26.62  327900.0
     8 │ 1980-12-19T00:00:00    28.25    28.38    28.25    28.25  217100.0
     9 │ 1980-12-20T00:00:00    28.25    28.38    28.25    28.25  217100.0     ⋯
    10 │ 1980-12-21T00:00:00    29.62    29.75    29.62    29.62  166800.0
    11 │ 1980-12-22T00:00:00    29.62    29.75    29.62    29.62  166800.0
   ⋮   │          ⋮              ⋮        ⋮        ⋮        ⋮           ⋮      ⋱
 12064 │ 2013-12-22T00:00:00   568.0    570.72   562.76   570.09       1.79038
 12065 │ 2013-12-23T00:00:00   568.0    570.72   562.76   570.09       1.79038 ⋯
 12066 │ 2013-12-24T00:00:00   569.89   571.88   566.03   567.67       5.9841e
 12067 │ 2013-12-25T00:00:00   569.89   571.88   566.03   567.67       5.9841e
 12068 │ 2013-12-26T00:00:00   568.1    569.5    563.38   563.9        7.286e6
 12069 │ 2013-12-27T00:00:00   563.82   564.41   559.5    560.09       8.0673e ⋯
 12070 │ 2013-12-28T00:00:00   563.82   564.41   559.5    560.09       8.0673e
 12071 │ 2013-12-29T00:00:00   557.46   560.09   552.32   554.52       9.0582e
 12072 │ 2013-12-30T00:00:00   557.46   560.09   552.32   554.52       9.0582e
 12073 │ 2013-12-31T00:00:00   554.17   561.28   554.0    561.02       7.9673e ⋯
=#

ddf3 = DateDataFrame(collect(ddf2.timestamp), ddf2.df)
ddf3[1:2, :]
#=
DateDataFrame: time::Vector{DateTime} span=> 1980-12-12T00:00:00->1980-12-13T00:00:00 extended df=2×13 DataFrame
 Row │ __date               Open     High     Low      Close    Volume    ExDi ⋯
     │ DateTime             Float64  Float64  Float64  Float64  Float64   Floa ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 1980-12-12T00:00:00    100.0    28.88    28.75    28.75  2.0939e6       ⋯
   2 │ 1980-12-13T00:00:00    100.0    28.88    28.75    28.75  2.0939e6
=#

using BenchmarkTools

@benchmark ddf2[DateTime(1980, 12, 13), :]
#=
BechmarkTools.Trial: 10000 samples with 636 evaluations.
 Range (min … max):  197.013 ns …   6.250 μs  ┊ GC (min … max): 0.00% … 95.22%
 Time  (median):     202.987 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   214.045 ns ± 190.064 ns  ┊ GC (mean ± σ):  2.89% ±  3.15%

  ▁▅▇██▇▆▆▆▆▅▃▃▃▃▃▂▁▁▃▃▃▁   ▁                       ▁           ▂
  ████████████████████████▇███▇████▇▆▇▅▆▆▅▅▅▅▇█▇████████▇▇▆▄▅▅▅ █
  197 ns        Histogram: log(frequency) by time        261 ns <

 Memory estimate: 96 bytes, allocs estimate: 2.
=#

@benchmark ddf3[DateTime(1980, 12, 13), :]
#=
BechmarkTools.Trial: 10000 samples with 535 evaluations.
 Range (min … max):  215.140 ns …   8.992 μs  ┊ GC (min … max): 0.00% … 96.14%
 Time  (median):     222.056 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   235.128 ns ± 261.696 ns  ┊ GC (mean ± σ):  3.63% ±  3.18%

    ▄▇█▇▆▅▅▅▅▄▃▂▂▁                  ▁ ▁ ▁                       ▂
  ▄█████████████████▇█▇▇▆▆▅▅▆▆▇▇▇████████████▇▇▆▆▄▆▅▅▅▄▂▃▄▄▄▄▄▄ █
  215 ns        Histogram: log(frequency) by time        288 ns <

 Memory estimate: 96 bytes, allocs estimate: 2.
=#

@benchmark ddf2[2, :]
#=
BechmarkTools.Trial: 10000 samples with 646 evaluations.
 Range (min … max):  196.594 ns …   6.969 μs  ┊ GC (min … max): 0.00% … 95.47%
 Time  (median):     201.703 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   213.108 ns ± 227.358 ns  ┊ GC (mean ± σ):  3.79% ±  3.44%

   ▅▇███▇▅▅▅▄▃▂▁▁                         ▁                     ▂
  ▆████████████████▇▇▆▆▆▆▇▅▄▃▅▆▅▅▄▆▇▆██████████▇▆▆▆▆▆▃▅▅▃▄▂▅▅▄▄ █
  197 ns        Histogram: log(frequency) by time        259 ns <

 Memory estimate: 96 bytes, allocs estimate: 2.
=#
```

