# --- Julia Script to Sort Files into Sample-Specific Folders ---

module FileSorter

export sort_sbml_files

"""
    sort_sbml_files(directory::String)

Scans a directory for .sbml files and moves them into subdirectories
named after their sample ID.

Assumes filenames are in the format 'SAMPLEID_rest_of_name.sbml',
for example: 'ERR1701760_bin.1.o.sbml'.

# Arguments
- `directory::String`: The path to the directory containing the .sbml files.
"""
function sort_sbml_files(directory::String)
    println("Scanning directory for .sbml files: ", directory)

    if !isdir(directory)
        @error "Directory not found: $directory"
        return
    end

    # Get a list of all files in the directory
    for filename in readdir(directory)
        source_path = joinpath(directory, filename)

        # Process only .sbml files that are not directories
        if isfile(source_path) && endswith(filename, ".sbml")
            try
                # --- Logic to Extract Sample ID ---
                # Splits "ERR1701760_bin.1.o.sbml" into ["ERR1701760", "bin.1.o.sbml"]
                # and takes the first part.
                parts = split(filename, "_")
                if isempty(parts)
                    @warn "Could not extract sample ID from '$filename'. Skipping."
                    continue
                end
                sample_id = parts[1]

                # --- File Movement Logic ---
                # 1. Define the target sample-specific directory
                sample_dir = joinpath(directory, sample_id)

                # 2. Create the directory if it doesn't exist
                if !isdir(sample_dir)
                    println("Creating new sample directory: ", sample_dir)
                    mkpath(sample_dir)
                end

                # 3. Define the final destination path for the file
                destination_path = joinpath(sample_dir, filename)

                # 4. Move the file
                println("Moving '$filename' -> '$sample_dir'")
                mv(source_path, destination_path)

            catch e
                @error "Failed to process '$filename'."
                @error "  Error: " e
            end
        end
    end
    println("\nFile sorting complete.")
end

end # module FileSorter


# --- Example Usage ---
# To run this script:
# 1. Make sure you are in the correct Julia environment.
# 2. Include the module: `include("FileSorter.jl")`
# 3. Use the module: `using .FileSorter`
# 4. Define the path to your files.
# 5. Call the function.

# using Pkg
# Pkg.activate("path/to/your/project") # Activate your project environment
# include("FileSorter.jl")
# using .FileSorter

# # !!! IMPORTANT !!!
# # Replace this with the actual path to your directory of .sbml files
# target_directory = "D:/met2map/metage2metabo_TARA/p1/GEMs_smbl"

# # Run the sorting function
# if isdir(target_directory)
#     sort_sbml_files(target_directory)
# else
#     println("Please update 'target_directory' to a valid path.")
# end
