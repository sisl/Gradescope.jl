module Gradescope

using JSON
using ZipFile
using Parameters

export ZipFile,
       addfile!,
       LEADERBOARD,
       set_stdout_visibility,
       set_leaderboard_value!,
       gradescope_output,
       metadata

include("zip.jl")
include("setup.jl")
# include("leaderboard.jl")
include("output.jl")


"""
    metadata()
    metadata(path)

Retrieves the submission metadata from a json file as a `Dict`.
See `https://gradescope-autograders.readthedocs.io/en/latest/submission_metadata/` for the metadata format.
"""
metadata(path="/autograder/submission_metadata.json") = JSON.parsefile(path)


end # module
