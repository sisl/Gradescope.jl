"""
Alias for optional fields with `missing` values. Note, T can also be a Union.
"""
const Optional{T} = Union{T, Missing}


"""
You can hide some or all test cases based on your desired conditions.

- `hidden`: test case will never be shown to students
- `after_due_date`: test case will be shown after the assignment's due date has passed. If late submission is allowed, then test will be shown only after the late due date.
- `after_published`: test case will be shown only when the assignment is explicitly published from the "Review Grades" page
- `visible` (default): test case will always be shown

See: https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format
"""
@enum VisibilityMode hidden after_due_date after_published visible


"""
You can specify the leaderboard sort order for a quantity by specifying an "order" property.
The default is "desc" for descending, i.e. higher scores rank higher.
"""
@enum LeaderboardOrder desc asc


"""
Gradescope leaderboard entry with objects defining the different
quantities to be displayed on the leaderboard.
See: https://gradescope-autograders.readthedocs.io/en/latest/leaderboards/
"""
@with_kw mutable struct LeaderboardEntry
    name::String
    value::Optional{Union{Number, String}}
    order::LeaderboardOrder = desc
end
LeaderboardEntry(name::String, value::Union{Number, String}) = LeaderboardEntry(name=name, value=value)


"""
Individual Gradescope test case.
See: https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format
"""
@with_kw mutable struct TestCase
    score::Optional{Float64} = missing # Optional, but required if not on top-level submission
    max_score::Optional{Float64} = missing # Optional maximum score for this test case
    name::Optional{String} = missing # Optional
    number::Optional{Float64} = missing # Optional, will just be numbered in order of array if no number given
    output::Optional{String} = missing # Optional text relevant to this test case
    tags::Vector{String} = [] # Optional tags
    visibility::Optional{VisibilityMode} = missing # Optional visibility setting
    extra_data::Dict = Dict() # Optional extra data to be stored
end


"""
Grdescope `results.json` format, which is the autograder output.
See: https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format
"""
@with_kw mutable struct Results
    score::Optional{Float64} = missing # Optional, but required if not on each test case below. Overrides total of tests if specified.
    execution_time::Optional{Float64} = missing # Optional, seconds
    output::Optional{String} = missing # Optional text relevant to the entire submission
    visibility::Optional{VisibilityMode} = missing # Optional visibility setting
    stdout_visibility::Optional{VisibilityMode} = missing # Optional stdout visibility setting
    extra_data::Dict = Dict() # Optional extra data to be stored
    tests::Vector{TestCase} = TestCase[] # Optional, but required if no top-level score
    leaderboard::Vector{LeaderboardEntry} = LeaderboardEntry[] # Optional, will set up leaderboards for these values
end


# Override so that `missing` data does not print in JSON file (previously printed as `null`).
import JSON.Writer.show_pair
show_pair(io::JSON.Writer.JSONContext, s, k, v::Missing) = nothing