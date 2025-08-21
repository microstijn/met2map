


module TaraBiosampleParser
using DataFrames
using CSV
using JSON
using DataConvenience
export parse_tara_metadata

"""
    parse_tara_metadata(filepath::String)

Parses the TARA Oceans project JSON file to extract all available
environmental and metadata attributes for each sample.

# Arguments
- `filepath::String`: The full path to the `PRJEB7988_metadata.json` file.

# Returns
- `DataFrame`: A DataFrame containing all extracted data.
"""
function parse_tara_metadata(filepath::String)
    println("Loading and parsing metadata from: $filepath")

    # --- 1. Load the JSON file ---
    if !isfile(filepath)
        @error "File not found: $filepath"
        return DataFrame()
    end
    full_data = JSON.parsefile(filepath)
    reports = full_data["reports"]
    println("Found metadata for $(length(reports)) samples.")

    # --- 2. Discover all unique attribute keys across all samples ---
    all_keys = Set{String}()
    for report in reports
        try
            attributes_list = report["assembly_info"]["biosample"]["attributes"]
            for attr in attributes_list
                push!(all_keys, attr["name"])
            end
        catch e
            # Ignore reports that might be missing the attributes section
        end
    end
    # Add the sample identifier key
    push!(all_keys, "sample_identifier")
    println("Discovered $(length(all_keys)) unique attributes across all samples.")

    # --- 3. Extract data into a list of dictionaries, ensuring all keys are present ---
    all_samples_data = []
    for report in reports
        try
            attributes_list = report["assembly_info"]["biosample"]["attributes"]
            sample_dict_raw = Dict(attr["name"] => attr["value"] for attr in attributes_list)
            
            # Create a new dictionary for this sample that will contain all possible keys
            standardized_dict = Dict{String, Any}()
            for key in all_keys
                standardized_dict[key] = get(sample_dict_raw, key, missing)
            end

            # Add the primary identifier
            standardized_dict["sample_identifier"] = get(sample_dict_raw, "sample_name", report["accession"])

            push!(all_samples_data, standardized_dict)
        catch e
            @warn "Could not process a report. Skipping. Error: $e"
        end
    end

    # --- 4. Construct the DataFrame ---
    df = DataFrame(all_samples_data)

    # --- 5. Post-processing: Clean up and convert types ---
    for col_name in names(df)
        if col_name == "sample_identifier"
            continue
        end

        new_col = []
        can_convert = true
        for val in df[!, col_name]
            if ismissing(val)
                push!(new_col, missing)
                continue
            end
            
            str_val = string(val)
            parsed_val = tryparse(Float64, str_val)

            if isnothing(parsed_val) || parsed_val == 99999
                if !ismissing(val)
                    can_convert = false
                    break
                end
                push!(new_col, missing)
            else
                push!(new_col, parsed_val)
            end
        end

        if can_convert
            println("Converting column '$col_name' to numeric.")
            df[!, col_name] = new_col
        end
    end

    # Reorder columns to have the sample identifier first
    select!(df, "sample_identifier", Not("sample_identifier"))
    cleannames!(df)
    return df
end

end # end module