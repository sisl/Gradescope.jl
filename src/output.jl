# Visibility modes have non-conventional type names so that their string output match the gradescope expected strings
# See: https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format

@enum VisibilityMode hidden after_due_date after_published visible

global const STDOUT_VIS = Ref(hidden)

get_stdout_visibility() = STDOUT_VIS.x
set_stdout_visibility(mode::VisibilityMode) = (STDOUT_VIS[] = mode)


"""
Gradescope output formatting.
See: https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format
"""
function gradescope_output(tests::Vector{Test}; leaderboard=false, kwargs...)
    for t in tests
        if isnothing(t.result)
            runtest!(t)
        end
    end

    infos = getproperty.(tests, :info)

    gradescope_output(infos; leaderboard=leaderboard, kwargs...)
end

function gradescope_output(tests::Vector{<:Dict}; leaderboard=false, kwargs...)
    output = Dict{Symbol, Any}(kwargs...)
    output[:tests] = tests
    output[:score] = sum(t[:score] for t in tests)

    extra_data = get!(output, :extra_data, Dict())
    extra_data[:language] = "julia"
    output[:stdout_visibility] = stdout_visibility()

    if leaderboard
        output[:leaderboard] = copy(LEADERBOARD)
    end

    return output
end

function gradescope_output(filename::AbstractString, tests; leaderboard=false, kwargs...)
    output = gradescope_output(tests; leaderboard=leaderboard, kwargs...)
    write(filename, json(output, 4))
end


"""
Write Gradescope formated JSON file to `results.json`
"""
writeresults(gradescope_json::Dict) = write("/autograder/results/results.json", json(gradescope_json, 4))