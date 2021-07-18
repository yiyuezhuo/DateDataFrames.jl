using DateDataFrames
using Test

using Test

using DateDataFrames
using DataFrames
using MarketData

@testset "DateDataFrames.jl" begin
    # Write your tests here.

    @testset "change ability and resample" begin
        df = DataFrame(AAPL) # TimeArray -> DataFrame
        ddf = DateDataFrame(DateTime.(df.timestamp), df[!, 2:end])
        ddf[DateTime(1980, 12, 12), :Open] = 100
        @test df[1, :Open] == 100
        ddf2 = resample(Nearest(), ddf, Day(1))
        ddf3 = DateDataFrame(collect(ddf2.timestamp), ddf2.df)
    end

    @testset "broadcasting" begin
        df = DataFrame(Dict(:a=>[1,2,3], :b=>[2,3,4]))
        ddf = DateDataFrame(DateTime(1989,6,4):Day(1):DateTime(1989,6,6), df)

        ddf2 = deepcopy(ddf)
        ddf2 .= 0

        @test ddf2[1,1] == 0

        ddf2 .= ddf

        @test ddf2[1,1] == 1

        ddf[!, :a] .= ddf2[!, :b] # ddf[!, :a] = ddf2[!, :b] is `setindex!`, not broadcasting. 

        @test ddf[1, :a] == 2

        ddf = ddf .* ddf

        @test ddf[1, :a] == 4

        ddf .= ddf .* ddf

        @test ddf[1, :a] == 16

        ddf[!, :b] .= 0

        @test ddf[1, :b] == 0

        ddf = ddf .* ddf[!, :b]

        @test ddf[1,1] == 0

        ddf_v = ddf[!, :a]
        ddf_v .= 1

        @test ddf_v[1] == 1

        ddf_v[:] .= 2

        @test ddf_v[1] == 2
    end
end
