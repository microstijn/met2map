# --- Julia Script to Convert GEMs to SBML ---

# First, ensure you have the necessary packages installed.
# You can run this once in the Julia REPL:
# using Pkg
# Pkg.add("COBRA")
#ENV["CPLEX_STUDIO_BINARIES"] = "D:/CPLEX/cplex/bin/"

# --- Module Definition ---
# Wrapping the function in a module makes it a reusable package component.
module GEMProcessor

using COBRA

# This makes the function available for use outside the module
export convert_xml_to_sbml

"""
    convert_xml_to_sbml(input_dir::String, output_dir::String)

Reads all .xml models from an input directory, renames them according to the
project's convention, and saves them as standardized .sbml files in
sample-specific subdirectories.

# Arguments
- `input_dir::String`: The path to the directory containing .xml GEMs.
- `output_dir::String`: The path where the new sample folders will be created.
"""
function convert_xml_to_sbml(input_dir::String, output_dir::String)
    println("Searching for .xml files in: ", input_dir)
    
    # Loop through all files in the input directory
    for filename in readdir(input_dir)
        if endswith(filename, ".xml")
            input_path = joinpath(input_dir, filename)
            
            # --- Filename and Folder Logic ---
            
            # 1. Extract the sample ID (e.g., "ERR1701760") from the filename
            sample_match = match(r"^(ERR\d+)", filename)
            if sample_match === nothing
                @warn "Could not extract sample ID from '$(filename)'. Skipping."
                continue
            end
            sample_id = sample_match.captures[1]

            # 2. Create the new, clean filename
            #    - Takes "ERR1701760_bin.1.o.xml"
            #    - Removes the final ".xml" extension
            #    - Replaces all remaining "." with "_"
            #    - Results in "ERR1701760_bin_1_o.sbml"
            base_name = first(split(filename, ".xml"))
            clean_base_name = replace(base_name, "." => "_")
            output_filename = clean_base_name * ".sbml"

            # 3. Create the sample-specific output directory
            sample_output_dir = joinpath(output_dir, sample_id)
            if !isdir(sample_output_dir)
                println("Creating new sample directory: ", sample_output_dir)
                mkpath(sample_output_dir)
            end
            
            # 4. Define the full final path for the new file
            output_path = joinpath(sample_output_dir, output_filename)
            
            println("\nProcessing '$(filename)' -> '$(output_path)'...")

            try
                # Use COBRA.jl to read the model.
                model = read_model(input_path)
                
                # Write the model back out in the standard SBML format
                save_model(model, output_path)
                
                println("Successfully converted and saved.")

            catch e
                @error "Could not process '$(filename)'. It may not be a valid metabolic model."
                @error "  Error: " e
            end
        end
    end
end

end # End of GEMProcessor module