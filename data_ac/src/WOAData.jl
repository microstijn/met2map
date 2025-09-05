#=
This module, WOAData, provides functionality for downloading World Ocean
Atlas (WOA) data from the NOAA NCEI servers for various release years.
=#
module WOAData

using Downloads
using Printf

# Export the public API functions and types
export download_woa_data, get_woa_options, WOAOptions, DownloadStatus

# --- Module Constants ---

# Base URL template for the WOA data. The year will be inserted.
const BASE_URL_TEMPLATE = "https://www.ncei.noaa.gov/data/oceans/woa/WOA<YEAR>/DATA"

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

# Defines the identifier for the main statistical mean climatology.
const STATISTICAL_MEAN_CLIMATOLOGY = "decav"

# For WOA23, some variables (like nutrients) use a different path ('all')
# for their monthly/seasonal statistical means.
const WOA23_ALL_CONVENTION_VARS = Set(["n", "p", "o", "si"])

"""
    DownloadStatus

A struct returned by `download_woa_data` to provide a detailed report on the download attempt.

# Fields
- `filepath::String`: The full local path for the target file.
- `url::String`: The remote URL that was constructed for the download.
- `status::Symbol`: The outcome of the operation (:downloaded, :skipped_exists, :failed).
- `message::String`: A human-readable summary of the outcome.
"""
struct DownloadStatus
    filepath::String
    url::String
    status::Symbol
    message::String
end


"""
    _download_woa_file(year, var_info, v, local_dir, gr_str, climatology, tp_code)

An internal helper function that constructs a URL, downloads a single WOA file,
and returns a DownloadStatus object.
"""
function _download_woa_file(year::Int, var_info, v::String, local_dir::String, gr_str::String, climatology::String, tp_code::String)
    path_name = var_info.path_name
    year_short = string(year)[3:4]
    res_info = RESOLUTION_MAP[gr_str]
    gr_path = res_info.path
    gr_code = res_info.code
    base_url = replace(BASE_URL_TEMPLATE, "<YEAR>" => year_short)

    local path_climatology
    local filename_climatology
    local official_filename

    if climatology == STATISTICAL_MEAN_CLIMATOLOGY
        tp_num = parse(Int, tp_code)
        if tp_num == 0
            path_climatology, filename_climatology = "decav", "decav"
        elseif 1 <= tp_num <= 12 # Monthly
            if year == 2023 && v in WOA23_ALL_CONVENTION_VARS
                path_climatology, filename_climatology = "all", "all"
            else
                path_climatology = "mon"
                filename_climatology = (year == 2023) ? "A5B7" : "all"
            end
        else # 13-16 for Seasons
             if year == 2023 && v in WOA23_ALL_CONVENTION_VARS
                path_climatology, filename_climatology = "all", "all"
            else
                path_climatology = "seas"
                filename_climatology = (year == 2023) ? "A5B7" : "all"
            end
        end
        official_filename = "woa$(year_short)_$(filename_climatology)_$(v)$(tp_code)_$(gr_code).nc"
    else
        path_climatology, filename_climatology = climatology, climatology
        official_filename = "woa$(year_short)_$(filename_climatology)_$(v)$(tp_code)_$(gr_code).nc"
    end
    
    download_url = join([base_url, path_name, "netcdf", path_climatology, gr_path, official_filename], '/')

    if !isdir(local_dir)
        mkpath(local_dir)
    end
    local_filepath = joinpath(local_dir, official_filename)

    if isfile(local_filepath)
        return DownloadStatus(local_filepath, download_url, :skipped_exists, "File already exists.")
    end
    
    try
        Downloads.download(download_url, local_filepath)
        return DownloadStatus(local_filepath, download_url, :downloaded, "Download successful.")
    catch e
        if isfile(local_filepath) rm(local_filepath) end
        return DownloadStatus(local_filepath, download_url, :failed, "Download failed: $(sprint(showerror, e))")
    end
end


"""
    WOAOptions

A container for all available download options. Get an instance via `get_woa_options()`.
"""
struct WOAOptions
    years::Vector{Int}
    variables::Dict{String, String}
    resolutions::Vector{String}
    climatologies::Dict{String, String}
    periods::Dict{String, Any}
end


"""
    get_woa_options() -> WOAOptions

Returns a `WOAOptions` struct containing all possible options for downloading WOA data.
"""
function get_woa_options()
    available_years = [2018, 2023]
    available_variables = Dict(k => v.path_name for (k, v) in VARIABLE_MAP)
    available_resolutions = sort(collect(keys(RESOLUTION_MAP)))
    available_climatologies = Dict(
        "decav" => "Primary statistical mean over all decades",
        "5564" => "1955-1964 decade average",
        "6574" => "1965-1974 decade average",
        "7584" => "1975-1984 decade average",
        "8594" => "1985-1994 decade average",
        "9504" => "1995-2004 decade average",
        "0517" => "2005-2017 decade average"
    )
    available_periods = Dict(
        "keywords" => ["annual"],
        "time_codes" => Dict("annual" => "00", "monthly" => "01-12", "seasonal" => "13-16"),
        "season_map" => Dict(13 => "Winter", 14 => "Spring", 15 => "Summer", 16 => "Autumn")
    )
    return WOAOptions(available_years, available_variables, available_resolutions, available_climatologies, available_periods)
end


"""
    download_woa_data(; output_dir, year, v, gr, climatology, period) -> DownloadStatus

Downloads a single World Ocean Atlas data file based on the specified parameters.

This function is designed to be called within a loop to download multiple files.

# Keyword Arguments
- `output_dir::String`: Root directory to save data.
- `year::Int`: WOA release year (e.g., 2018, 2023).
- `v::String`: A single variable to download (e.g., "t", "s").
- `gr::Union{String, Real}`: The grid resolution (e.g., "1.00", 0.25).
- `climatology::String`: The dataset decade to use (e.g., "decav", "5564").
- `period::Union{String, Int}`: The averaging period.
  - `"annual"`: For the annual average (time period 00).
  - `Int`: For a specific time period (e.g., `1` for Jan, `13` for Winter).

# Returns
- `DownloadStatus`: An object containing the filepath, url, status, and a message.
"""
function download_woa_data(;
    output_dir::String,
    year::Int,
    v::String,
    gr::Union{String, Real},
    climatology::String,
    period::Union{String, Int}
)
    # --- Input Sanitization and Normalization ---
    gr_str = gr isa Real ? @sprintf("%.2f", gr) : gr
    if !haskey(RESOLUTION_MAP, gr_str)
        @error "Invalid grid resolution: '$gr'. Please choose from $(keys(RESOLUTION_MAP))."
        return
    end

    if !haskey(VARIABLE_MAP, v)
        @error "Variable '$v' is not a known variable. Skipping."
        return
    end
    var_info = VARIABLE_MAP[v]

    tp_code = if period isa String
        p_lower = lowercase(period)
        p_lower == "annual" ? "00" : lpad(period, 2, '0')
    else # Int
        lpad(period, 2, '0')
    end
    
    println("-"^40)
    @printf "Requesting: Var=%s, Year=%d, Res=%s, Climatology=%s, Period=%s\n" v year gr_str climatology tp_code

    # --- Download Process ---
    output_path = joinpath(output_dir, string(year), v, gr_str, climatology)
    status_result = _download_woa_file(year, var_info, v, output_path, gr_str, climatology, tp_code)

    # --- Report and Return ---
    if status_result.status == :downloaded
        println("Success: File downloaded to $(status_result.filepath)")
    elseif status_result.status == :skipped_exists
        println("Skipped: $(status_result.message) at $(status_result.filepath)")
    else # :failed
        println("Failed: $(status_result.message)")
        println("URL attempted: $(status_result.url)")
    end
    println("-"^40)
    
    return status_result
end

end # module WOAData

