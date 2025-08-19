# --- Julia Script to Convert GEMs to SBML ---

# First, ensure you have the necessary packages installed.
# You can run this once in the Julia REPL:
# using Pkg
# Pkg.add("COBREXA")
#ENV["CPLEX_STUDIO_BINARIES"] = "D:/CPLEX/cplex/bin/"

# --- Module Definition ---
# Wrapping the function in a module makes it a reusable package component.
module GEMProcessor

using COBREXA
import SBMLFBCModels: SBMLFBCModel
# This makes the function available for use outside the module
export convert_xml_to_sbml

"""
    convert_xml_to_sbml(input_dir::String, output_dir::String)

Reads all .xml models from an input directory and saves them as 
standardized .sbml files in the specified output directory using COBREXA.jl.

# Arguments
- `input_dir::String`: The path to the directory containing .xml GEMs.
- `output_dir::String`: The path where the converted .sbml files will be saved.
"""
function convert_xml_to_sbml(input_path::String, output_dir::String)
 
    # Ensure the main output directory exists
    if !isdir(output_dir)
        println("Creating output directory: ", output_dir)
        mkpath(output_dir)
    end

    # Get just the filename for logging
    filename = basename(input_path)
    # Print which thread is handling which file
    println("Thread $(Threads.threadid()): Processing '$(filename)'...")

    # Define the output path
    output_filename = replace(filename, ".xml" => ".sbml")
    output_path = joinpath(output_dir, output_filename)

    temp_path = "" # Initialize empty temp_path

    if endswith(filename, ".xml")
        
        # --- Filename Logic ---
        # Simply replace the .xml extension with .sbml
        output_filename = replace(filename, ".xml" => ".sbml")
        
        # Define the full final path for the new file in the main output directory
        output_path = joinpath(output_dir, output_filename)
        
        println("\nProcessing '$(filename)' -> '$(output_path)'...")
        try
            # Use the COBREXA.jl function to load the model into a standard format.
            model = load_model(input_path, SBMLFBCModel);
            
            # Use the COBREXA.jl function to save the model.
            save_model(model, output_path, SBMLFBCModel);
            
            println("Successfully converted and saved.")
        catch e
            @error "Could not process '$(filename)'. It may not be a valid metabolic model."
            @error "  Error: " e
        end
    end
    
end

end # End of GEMProcessor module
