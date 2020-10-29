using JSON3
using ProgressBars

function distill(path::String, datafilter::RedditDataFilter)
    file = getfile(path)
    data_vector = Vector{Dict{Symbol,Any}}
    multithreaded = Threads.nthreads() > 1
    values = multithreaded ? [data_vector() for t = 1:Threads.nthreads()] : data_vector()
    decompressor_stream = get_decompressor_stream(file)
    open(decompressor_stream, file) do stream
        bar = ProgressBar(eachline(stream))
        bar.description = "File: $(basename(file)); Threads: $(Threads.nthreads())"
        for line in bar
            if multithreaded
                Threads.@spawn begin
                    if contains(line, datafilter)
                        linedata = JSON3.read(line)
                        if contains(linedata, datafilter)
                            data = convert(Dict, linedata)
                            data = filter(datafilter, data)
                            fetched_data = fetch(data)
                            push!(values[Threads.threadid()], fetched_data)
                        end
                    end
                end
            else
                if contains(line, datafilter)
                    linedata = JSON3.read(line)
                    if contains(linedata, datafilter)
                        data = convert(Dict, linedata)
                        data = filter(datafilter, data)
                        push!(values, data)
                    end
                end
            end
        end
    end
    return multithreaded ? collect(Iterators.flatten(values)) : values
end
