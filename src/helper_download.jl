# 1. Export 
export download_data

# 2. Add dependencies
using Downloads
using URIs

# 3. functions
"""
    download_data(url::String, output_dir::String; ...)

Downloads a file, automatically detecting the file extension from URL
parameters like '?format=zip'.

# Arguments
- `url::String`: The URL of the file to download.
- `output_dir::String`: The path to an existing base directory for the download.
- `force_overwrite::Bool`: (Keyword, default: `false`) Controls file overwriting.
- `create_subfolder::Union{String, Nothing}`: (Keyword, default: `nothing`) If a string is provided,
  a subfolder with that name will be created inside `output_dir`.
"""
function download_data(url::String, output_dir::String; force_overwrite::Bool=false, create_subfolder::Union{String, Nothing}=nothing)
    # 1. Validate that the main output directory exists.
    if !isdir(output_dir)
        println("ERROR: The base output directory '", output_dir, "' does not exist.")
        return
    end

    # 2. Determine the final destination directory.
    final_destination_dir = output_dir
    if create_subfolder isa String
        final_destination_dir = joinpath(output_dir, create_subfolder)
        if !isdir(final_destination_dir)
            mkdir(final_destination_dir)
            println("Created new subfolder: ", final_destination_dir)
        end
    end

    if isempty(url)
        println("Warning: Received an empty URL. Skipping.")
        return
    end

    # AUTOMATIC EXTENSION DETECTION 
    # Parse the URL into its components (path, query, etc.)
    uri = URI(url)
    query_params = queryparams(uri)
    
    # Get the base filename from the URL's path.
    base_filename = basename(uri.path)
    # Safely get the value of the 'format' parameter, defaulting to "" if not found.
    ext = get(query_params, "format", "")
    
    # Combine the base name and extension if an extension was found.
    filename = isempty(ext) ? base_filename : "$base_filename.$ext"
    

    output_path = joinpath(final_destination_dir, filename)

    if isfile(output_path)
        if force_overwrite
            println("File exists. Forcing overwrite as requested.")
        else
            print("File '", filename, "' already exists in '", final_destination_dir, "'. Overwrite? (yes/no): ")
            answer = readline()
            
            if !(lowercase(strip(answer)) in ("yes", "y"))
                println("Skipping download.")
                return 
            end
            
            println("Proceeding with overwrite...")
        end
    end

    println("Attempting to download '", filename, "' to '", final_destination_dir, "'")
    
    try
        Downloads.download(url, output_path)
        println("SUCCESS: Downloaded '", filename, "'.")
    catch e
        println("ERROR: Failed to download '", filename, "'. Details: ", e)
    end
end

