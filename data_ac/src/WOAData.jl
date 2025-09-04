#=
This module provides functionality for downloading World Ocean
Atlas (WOA) data from the NOAA NCEI servers for various release years.
=#
module WOAData

using Downloads
using Printf

# Export the public API function
export download_woa_data

# Constants 

# Base URL template for the WOA data. The year will be inserted.
const BASE_URL_TEMPLATE = "https://www.ncei.noaa.gov/data/oceans/woa/WOA<YEAR>/DATA/"

# A map to link the short variable names to the paths and filename prefixes
# used on the NCEI server. Using NamedTuples for clarity.
const VARIABLE_MAP = Dict(
    "t" => (path_name="temperature", filename_prefix="t"),
    "s" => (path_name="salinity", filename_prefix="s"),
    "o" => (path_name="oxygen", filename_prefix="o"),
    "p" => (path_name="phosphate", filename_prefix="p"),
    "n" => (path_name="nitrate", filename_prefix="n"),
    "si" => (path_name="silicate", filename_prefix="si"),
    "i" => (path_name="ice_coverage", filename_prefix="i")
)

# Maps the user-friendly resolution string to the path component and
# filename code used on the NCEI server.
const RESOLUTION_MAP = Dict(
    "1.00" => (path="1.00", code="01"),
    "0.25" => (path="0.25", code="04"),
    "5.00" => (path="5deg", code="5d")
)


"""
    _download_woa_file(year, var_info, var_short, local_dir, resolution, averaging, time_period)

An internal helper function that constructs a URL and downloads a single WOA file.
"""
function _download_woa_file(year::Int, var_info, var_short, local_dir, resolution, averaging, time_period)
    # Access elements of the NamedTuple by name for improved readability
    path_name = var_info.path_name
    filename_prefix = var_info.filename_prefix
    
    # Get the two-digit year code (e.g., 18 for 2018)
    year_short = string(year)[3:4]
    
    # Get the path and code for the specified resolution
    res_info = RESOLUTION_MAP[resolution]
    resolution_path = res_info.path
    resolution_code = res_info.code

    # 1. Construct the download URL
    base_url = replace(BASE_URL_TEMPLATE, "<YEAR>" => year_short)
    filename = "woa$(year_short)_$(averaging)_$(filename_prefix)$(time_period)_$(resolution_code).nc"
    
    download_url = joinpath(base_url, path_name, "netcdf", averaging, resolution_path, filename)

    # 2. Set up the local destination path
    if !isdir(local_dir)
        println("Creating directory: $local_dir")
        mkpath(local_dir)
    end
    local_filepath = joinpath(local_dir, filename)

    # 3. Check if the file already exists
    if isfile(local_filepath)
        println("File already exists, skipping: $local_filepath")
        println("-"^40)
        return
    end

    # 4. Download the file
    println("Downloading from: $download_url")
    println("Saving to:        $local_filepath")
    
    try
        Downloads.download(download_url, local_filepath)
        println("Download complete.")
    catch e
        @error "Failed to download file for variable '$var_short' (Year: $year, Res: $resolution, Avg: $averaging, Time: $time_period). Error: $e"
        # If download fails, remove potentially incomplete file
        if isfile(local_filepath)
            rm(local_filepath)
        end
    end
    println("-"^40)
end


"""
    download_woa_data(; output_dir="...", year=2023, variables=nothing, resolution="1.00", averaging="decav", time_periods="00")

Downloads World Ocean Atlas variables for a specific release year, resolution, and averaging period.

This is the main public function for the module.

# Keyword Arguments
- `output_dir::String`: The root directory where the data will be saved. Defaults to "/data/scratch/globc/dlim/WOA_downloaded/".
- `year::Int`: The WOA release year to download (e.g., 2018, 2023). Defaults to 2023.
- `variables::Union{String, Vector{String}, Nothing}`: The variable(s) to download (e.g., "t", ["t", "s"]). Defaults to all variables.
- `resolution::String`: The grid resolution. Valid options: "1.00", "0.25", "5.00". Defaults to "1.00".
- `averaging::String`: The averaging period type (e.g., "decav", "mon", "seas"). Defaults to "decav" (decadal average).
- `time_periods::Union{String, Vector{String}}`: The time period code(s). For annual data ("decav"), use "00". For monthly ("mon"), use "01"-"12". For seasonal ("seas"), use "13"-"16". Defaults to "00".
"""
function download_woa_data(;
    output_dir::String="/data/scratch/globc/dlim/WOA_downloaded/",
    year::Int=2023,
    variables::Union{String, Vector{String}, Nothing} = nothing,
    resolution::String="1.00",
    averaging::String="decav",
    time_periods::Union{String, Vector{String}}="00"
)
    println("Starting WOA data download process for year $year.")

    # Validate resolution input
    if !haskey(RESOLUTION_MAP, resolution)
        @error "Invalid resolution: '$resolution'. Please choose from $(keys(RESOLUTION_MAP))."
        return
    end
    
    # Determine which variables to process
    local vars_to_process
    if isnothing(variables)
        vars_to_process = keys(VARIABLE_MAP)
        println("All available variables will be downloaded.")
    elseif variables isa String
        vars_to_process = [variables] # Convert single string to a collection
    else # It must be a Vector{String}
        vars_to_process = variables
    end

    # Determine which time periods to process
    local periods_to_process = time_periods isa String ? [time_periods] : time_periods

    # Create a year-specific subdirectory
    year_output_dir = joinpath(output_dir, string(year))
    println("Output directory: $year_output_dir")
    println("-"^40)

    for var_short in vars_to_process
        if !haskey(VARIABLE_MAP, var_short)
            @warn "Variable '$var_short' is not a known variable. Skipping."
            continue
        end
        var_info = VARIABLE_MAP[var_short]
        @printf "Processing variable: '%s'\n" var_short
        
        # Create a more specific output path to organize data
        output_path = joinpath(year_output_dir, var_short, resolution, averaging)

        for time_period in periods_to_process
            _download_woa_file(year, var_info, var_short, output_path, resolution, averaging, time_period)
        end
    end
    
    println("Download process complete for year $year.")
end

end # module met2map

