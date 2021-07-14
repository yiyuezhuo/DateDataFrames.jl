using DateDataFrames
using Test

using Test

using DateDataFrames
using DataFrames
using MarketData

@testset "DateDataFrames.jl" begin
    # Write your tests here.

    df = DataFrame(AAPL) # TimeArray -> DataFrame
    ddf = DateDataFrame(DateTime.(df.timestamp), df[!, 2:end])
    ddf[DateTime(1980, 12, 12), :Open] = 100
    @test df[1, :Open] == 100
    ddf2 = resample(Nearest(), ddf, Day(1))
    ddf3 = DateDataFrame(collect(ddf2.timestamp), ddf2.df)
end
