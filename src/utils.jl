using CodecBzip2
using CodecZstd
using CodecXz
using CodecZlib
using TranscodingStreams

decompression_codecs = Dict(
    "bz2" => Bzip2DecompressorStream,
    "zst" => ZstdDecompressorStream,
    "xz" => XzDecompressorStream,
    "gz" => GzipDecompressorStream,
)

get_decompressor_stream(filename::String) =
    get(decompression_codecs, split(filename, ".") |> last, NoopStream)

function getfile(path::String)
    if isdir(path)
        files = readdir(path, join = true)
        if length(files) > 1
            @warn "More than one file in directory ($path). Using first file."
        end
        return files |> first
    else
        return path
    end
end
