using Parameters

@with_kw struct RedditDataFilter
    fields::Vector{String} = String[]
    author::Vector{String} = String[]
    subreddit::Vector{String} = String[]
end


RedditDataFilter(fields::String, author::Vector{String}, subreddit::Vector{String}) =
    RedditDataFilter(fields = [fields], author = author, subreddit = subreddit)
RedditDataFilter(fields::Vector{String}, author::String, subreddit::Vector{String}) =
    RedditDataFilter(fields = fields, author = [author], subreddit = subreddit)
RedditDataFilter(fields::Vector{String}, author::Vector{String}, subreddit::String) =
    RedditDataFilter(fields = fields, author = author, subreddit = [subreddit])

RedditDataFilter(fields::String, author::String, subreddit::Vector{String}) =
    RedditDataFilter(fields = [fields], author = [author], subreddit = subreddit)
RedditDataFilter(fields::String, author::Vector{String}, subreddit::String) =
    RedditDataFilter(fields = [fields], author = author, subreddit = [subreddit])
RedditDataFilter(fields::Vector{String}, author::String, subreddit::String) =
    RedditDataFilter(fields = fields, author = [author], subreddit = [subreddit])

RedditDataFilter(fields::String, author::String, subreddit::String) =
    RedditDataFilter(fields = [fields], author = [author], subreddit = [subreddit])
