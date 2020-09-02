module Gradescope

using JSON
using ZipFile
using Parameters

export Results,
       TestCase,
       LeaderboardEntry,
       VisibilityMode,
       LeaderboardOrder,
       ZipFile,
       addfile!,
       set_stdout_visibility,
       gradescope_output,
       metadata

include("gradescope_types.jl")
include("zip.jl")
include("setup.jl")
include("output.jl")

# Export enums
for enum in [VisibilityMode, LeaderboardOrder], e in instances(enum)
    @eval export $(Symbol(e))
end

end # module
