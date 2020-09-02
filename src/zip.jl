using ZipFile

"""
Wrapper around `ZipFile.addfile` to read contents of files and add them into a zip file.
"""
addfile!(w::ZipFile.Writer, filenames::Vector{String}; kwargs...) = map(filename->addfile!(w, filename), filenames)
function addfile!(w::ZipFile.Writer, filename::String; kwargs...)
    f = ZipFile.addfile(w, basename(filename); kwargs...)
    write(f, read(filename, String))
    close(f)
end