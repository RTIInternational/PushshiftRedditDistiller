using PushshiftRedditDistiller
using Test
using DataDeps

ENV["DATADEPS_ALWAYS_ACCEPT"] = true
ENV["CI"] = true

@testset "PushshiftRedditDistiller.jl" begin
    filter = RedditDataFilter()
    @test isempty(filter.author)
    @test isempty(filter.subreddit)
    @test isempty(filter.fields)

    sample_submissions = distill(datadep"reddit-submissions-sample", filter)
    @test length(sample_submissions) == 1000

    sample_comments = distill(datadep"reddit-comments-sample", filter)
    @test length(sample_comments) == 10000
end