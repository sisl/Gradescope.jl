"""
    metadata()
    metadata(path)

Retrieves the submission metadata from a json file as a `Dict`.
See `https://gradescope-autograders.readthedocs.io/en/latest/submission_metadata/` for the metadata format.
"""
metadata(path="/autograder/submission_metadata.json") = JSON.parsefile(path)


"""
    output(results::Results)
    output(results::Dict)

Write Gradescope output formatted JSON file to `results.json`
See: https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format
"""
output(results::Union{Results, Dict}) = write("/autograder/results/results.json", json(results, 4))