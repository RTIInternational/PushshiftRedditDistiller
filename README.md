# PushshiftRedditDistiller

This package is intended to assist with downloading, extracting, and distilling the monthly reddit data dumps made available through [pushshift.io](https://files.pushshift.io/reddit/).

# Example Use

## Preexisting File
If you already have a monthly submissions or comments file downloaded:

```julia
julia> using PushshiftRedditDistiller

julia> filter = RedditDataFilter(author=["spez"])

julia> spez_comments = distill("~/Downloads/RC_2005-12.bz2", filter)

julia> length(spez_comments)
7

julia> typeof(spez_comments)
Array{Dict{Symbol,Any},1}

julia> first(spez_comments)
Dict{Symbol,Any} with 18 entries:
  :author_flair_css_class => nothing
  :gilded                 => 0
  :parent_id              => "t3_17942"
  :score                  => 4
  :link_id                => "t3_17942"
  :created_utc            => 1134392748
  :author_flair_text      => nothing
  :distinguished          => nothing
  :author                 => "spez"
  :stickied               => false
  :subreddit              => "reddit.com"
  :subreddit_id           => "t5_6"
  :id                     => "c53"
  :retrieved_on           => 1473738414
  :body                   => "still looks like a death trap to me..."
  :controversiality       => 0
  :ups                    => 4
  :edited                 => false
```

## DataDeps Catalog

All monthly comment and submissions files are cataloged and available using [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl). The format for the `datadep` string macros are `reddit-comments-YYYY-MM` for comments and `reddit-submissions-YYYY-MM` for submissions.

If the file isn't downloaded, you will be prompted to download that archive file before processing.

```julia
julia> using DataDeps

julia> more_spez_comments = distill(datadep"reddit-comments-2006-04", filter)
This program has requested access to the data dependency reddit-comments-2006-04.
which is not currently installed. It can be installed automatically, and you will not see this message again.

Baumgartner, J., Zannettou, S., Keegan, B., Squire, M., & Blackburn, J. (2020, May). 
The pushshift reddit dataset.
In Proceedings of the International AAAI Conference on Web and Social Media 
(Vol. 14, pp. 830-839).



Do you want to download the dataset from https://files.pushshift.io/reddit/comments/RC_2006-04.bz2 to "~/.julia/datadeps/reddit-comments-2006-04"?
[y/n]
y

┌ Info: Downloading
│   source = "https://files.pushshift.io/reddit/comments/RC_2006-04.bz2"
│   dest = "~/.julia/datadeps/reddit-comments-2006-04/RC_2006-04.bz2"
│   progress = 1.0
│   time_taken = "0.51 s"
│   time_remaining = "0.0 s"
│   average_speed = "3.729 MiB/s"
│   downloaded = "1.891 MiB"
│   remaining = "0 bytes"
└   total = "1.891 MiB"
┌ Warning: Checksum not provided, add to the Datadep Registration the following hash line
│   hash = "1e757b8a7dd4b1f7281329ac77cf4a20f59571d59899983fd7f347b24b081516"

julia> length(more_spez_comments)
19
```

## Multithreaded Support

If you start Julia with more than one thread available, multithreading will be enabled. It's best to play around with the number of threads for a bit if you're looking to optimize parsing speed, as it depends on how complex your filter is and the decompression algorithm available. For example, slower decompression algorithms (`bz2`) will bottleneck the speed in which you can feed lines from the stream to each thread to parse. For faster algorithms, you may have a strict filter that doesn't result in many lines needing to be fully parsed, making the overhead of coordinating threads costly.

The number of threads used while parsing will be displayed in the progress bar.

```bash
$ julia -t 3
```
...

```julia
julia> results = distill(datadep"reddit-comments-2006-04", filter)
File: RC_2006-04.bz2; Threads: 3 ┣ ╱   ╱   ╱   ╱   ╱   ╱   ╱   ╱   ╱ ┫ 19090it 00:01 [35469.7 it/s]
```


## Filtering with `RedditDataFilter`

Data can be filtered on the `author` or `subreddit` field currently. The filtering is currently disjunctive (OR), so if both `author` and `subreddit` are passed, it will return data from those author(s) OR those subreddit(s).

In addition, you can control which fields are returned with the `fields` argument.

All arguments are of type `Vector{String}`, though passing a single string to an argument will convert it to a length 1 `Vector`.

**Note that no checking of correct field names is done for you, since the fields available change over time**

```julia
julia> using Dates

julia> timestamps_only = RedditDataFilter(fields=["created_utc"])

julia> timestamp_comments = distill(datadep"reddit-comments-2006-04", timestamps_only)

julia> Dates.unix2datetime(first(timestamp_comments)[:created_utc])
2006-04-01T00:00:55
```

## Other Usage Notes

### Exporting

`distill` returns `Vector{Dict{Symbol,Any}}`, which can be fed into a `DataFrame` from [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) (not included).

```julia
julia> using DataFrames, CSV

julia> spez_comments_df = DataFrame(spez_comments)

julia> CSV.write("spez_comments.csv", spez_comments_df, quotestrings=true)
```

### Managing DataDeps

Some of the files are large - if you were to download the whole archive it would be over one TB. Because of this, you may want to remove a file after use or change your DataDeps download directory to another drive.

**Removal**

```julia
julia> rm(datadep"reddit-comments-2006-04", recursive=true)
```

**New Directory**

```julia
julia> download_path = "/Users/user/pushshift-datadeps"

julia> mkdir(download_path)

julia> ENV["DATADEPS_LOAD_PATH"] = download_path

julia> ENV["DATADEPS_NO_STANDARD_LOAD_PATH"] = true
```

### Accessing File Metadata

These are used to create the datadeps. Useful in case you want to know the direct file names and want to use another data dependency management tool.


```julia
julia> PushshiftRedditDistiller.comments_metadata
169-element Array{NamedTuple{(:file, :name),Tuple{String,String}},1}:
 (file = "RC_2005-12.bz2", name = "2005-12")
 ⋮
 (file = "RC_2019-12.zst", name = "2019-12")
```

