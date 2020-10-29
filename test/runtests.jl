using PushshiftRedditDistiller
using Test
using DataDeps

ENV["DATADEPS_ALWAYS_ACCEPT"] = true
ENV["CI"] = true

@testset "Empty Filters" begin
    test_filter = RedditDataFilter()
    @test isempty(test_filter.author)
    @test isempty(test_filter.subreddit)
    @test isempty(test_filter.fields)

    sample_submissions = distill(datadep"reddit-submissions-sample", test_filter)
    @test length(sample_submissions) == 1000

    sample_comments = distill(datadep"reddit-comments-sample", test_filter)
    @test length(sample_comments) == 10000
end

@testset "Filters" begin
    author = "[deleted]"
    filter_author = RedditDataFilter(author=[author])
    deleted_author_comments = distill(datadep"reddit-comments-sample", filter_author)
    @test length(deleted_author_comments) > 0
    @test all(get.(deleted_author_comments, :author, nothing) .== author)

    subreddit = "AskReddit"
    filter_subreddit = RedditDataFilter(subreddit=[subreddit])
    test_subreddit_comments = distill(datadep"reddit-comments-sample", filter_subreddit)
    @test length(test_subreddit_comments) > 0
    @test all(get.(test_subreddit_comments, :subreddit, nothing) .== subreddit)

    field = "created_utc"
    filter_field = RedditDataFilter(fields=[field])
    test_field_comments = distill(datadep"reddit-comments-sample", filter_field)
    @test all(first.(keys.(test_field_comments)) .== Symbol(field))
end