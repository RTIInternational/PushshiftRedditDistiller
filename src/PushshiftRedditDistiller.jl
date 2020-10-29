module PushshiftRedditDistiller

using DataDeps

export RedditDataFilter, distill

include("deps.jl")
include("types.jl")
include("distiller.jl")
include("filter.jl")
include("utils.jl")

function __init__()
    init_deps()
end


end
