"""
Create the `setup.sh` file for Gradescope.

This downloads the Julia executable, adds it to the PATH,
adds required Julia packages, and precompiles everything.

- `julia_version` is the VersionNumber for the Julia version to download.
- `packages` is the list of required packages to add, can be a URL for unregistered packages.
"""
function create_setup(; julia_version::VersionNumber=v"1.2", packages::Vector{String}=String[])
    filename::String = "setup.sh"
    tarname::String = "julia-$julia_version-linux-x86_64.tar.gz"
    linux_url::String = "https://julialang-s3.julialang.org/bin/linux/x64/$(julia_version.major).$(julia_version.minor)/$tarname"

    # Download the Julia executable, unzip it, and add the bin directory to the PATH
    filecontent::String = """
    #!/usr/bin/env bash

    wget $linux_url
    tar xvf $tarname
    export PATH=\$PATH:\$(pwd)/julia-$julia_version/bin
    """

    # Add required Julia packages and precompile them.
    if !isempty(packages)
        # direct links to unregistered packages
        url_pkgs::Vector{String} = filter(pkg->startswith(pkg, "http"), packages)

        # registered named packages
        named_pkgs::Vector{String} = setdiff(packages, url_pkgs)

        # join package names to be added via Pkg.add([])
        added_pkgs::String = join(map(pkg->"\"$pkg\"", named_pkgs), ", ")

        # join URL package names to be added via Pkg.add([PackageSpec(...)])
        added_pkgs_urls::String = join(map(pkg->"PackageSpec(url=\"$pkg\")", url_pkgs), ", ")
        unregistered_added_pkgs::String = isempty(added_pkgs_urls) ? "" : "; Pkg.add([$added_pkgs_urls])"

        # remove any .git and .jl to get the package name from the URL
        named_pkgs_from_urls::Vector{String} = map(name->replace(name, r"(\.git|\.jl)"=>""), basename.(url_pkgs))
        pkgs2use::Vector{String} = vcat(named_pkgs, named_pkgs_from_urls)

        # call `using` on each package to precompile
        using_pkgs::String = join(string.("using ", pkgs2use), "; ")

        # Pkg.precompile all dependencies (different for pre v1.3)
        if julia_version < v"1.3"
            pkg_precompile = "Pkg.API.precompile()"
        else
            pkg_precompile = "Pkg.precompile()"
        end

        # put it all together into the file contents
        filecontent *= """\n
        julia -e 'using Pkg; Pkg.add([$added_pkgs])$unregistered_added_pkgs'
        julia -e 'using Pkg; $pkg_precompile'
        julia -e '$using_pkgs'
        """
    end

    # Confirm that `julia` is available on the PATH
    filecontent *= "\nwhich julia"

    open(filename, "w+") do f
        write(f, filecontent)
    end
end




"""
Create `run_autograder` file used by Gradescope.
- `julia_version` is the Julia version downloaded by `setup.sh` and added to PATH.
- `dir` is the root directory of the `submission` and `source` folders (change when testing locally)

This assumes the bulk of the autograder is done in the Julia file `run_autograder.jl`.
"""
function create_run_autograder(jl_autograder::String="run_autograder.jl"; julia_version::VersionNumber=v"1.2", dir="/autograder")
    filename::String = "run_autograder"

    filecontent::String = """
    #!/usr/bin/env bash

    export PATH=\$PATH:/julia-$julia_version/bin
    cp -r $dir/submission/* $dir/source/
    cd $dir/source
    julia --color=yes $jl_autograder
    """

    open(filename, "w+") do f
        write(f, filecontent)
    end
end
