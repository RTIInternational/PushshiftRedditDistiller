linevalue(key::String, value::String) = "\"$key\":\"$value\""

function Base.contains(line::String, datafilter::RedditDataFilter)
    if isempty(datafilter.author) && isempty(datafilter.subreddit)
        return true
    else
        authorcheck = any(contains.(line, linevalue.("author", datafilter.author)))
        subredditcheck = any(contains.(line, linevalue.("subreddit", datafilter.subreddit)))
        return any([authorcheck, subredditcheck])
    end
end

function Base.contains(json::JSON3.Object, datafilter::RedditDataFilter)
    if isempty(datafilter.author) && isempty(datafilter.subreddit)
        return true
    else
        authorcheck = get(json, :author, nothing) ∈ datafilter.author
        subredditcheck = get(json, :subreddit, nothing) ∈ datafilter.subreddit
        return any([authorcheck, subredditcheck])
    end
end

function Base.filter(datafilter::RedditDataFilter, data::Dict{Symbol,Any})
    if isempty(datafilter.fields)
        return data
    else
        incols(x) = x ∈ Symbol.(datafilter.fields)
        return filter(d -> incols(d.first), data)
    end
end
