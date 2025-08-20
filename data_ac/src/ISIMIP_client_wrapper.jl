# Julia Wrapper for the Python ISIMIP Client

using PyCall
using Conda
using DataFrames

# Installation of the Python Library
# This part ensures that the Python `isimip-client` is installed in a
# Conda environment that PyCall can use.

try
    # Check if the library is already installed and importable
    pyimport("isimip_client")
    println("Python 'isimip-client' is already installed.")
catch
    println("Python 'isimip-client' not found. Installing it now via pip...")
    # Use Conda.jl to run pip and install the library
    Conda.pip_interop(true)
    Conda.pip("install", "isimip-client")
    println("Installation complete.")
end


# Module Definition 
# Encapsulates the Julia wrapper for the Python client.
module ISIMIPClientPy

using PyCall
using DataFrames

export ISIMIPClient, datasets, files, download_file

# This constant will hold the imported Python ISIMIPClient class
const ISIMIPClientClass = PyNULL()

function __init__()
    # This function runs when the module is first loaded.
    # It imports the Python class and stores it in our constant.
    copy!(ISIMIPClientClass, pyimport("isimip_client.client").ISIMIPClient)
end

"""
    ISIMIPClient

A Julia wrapper for the Python ISIMIPClient object.
"""
struct ISIMIPClient
    py_client::PyObject
end

# Constructor to create a Julia client instance
function ISIMIPClient(;kwargs...)
    # This creates an instance of the Python class
    py_client_instance = ISIMIPClientClass(;kwargs...)
    # And wraps it in our Julia struct
    ISIMIPClient(py_client_instance)
end

"""
    datasets(client::ISIMIPClient; kwargs...)

Searches for datasets using keyword arguments as filters. This function
calls the `datasets` method of the underlying Python client.
"""
function datasets(client::ISIMIPClient; kwargs...)
    # PyCall automatically converts the Julia keyword arguments
    # into Python keyword arguments.
    println("Querying for datasets...")
    return client.py_client.datasets(;kwargs...)
end

"""
    files(client::ISIMIPClient; kwargs...)

Searches for individual files using keyword arguments as filters. This function
calls the `files` method of the underlying Python client.
"""
function files(client::ISIMIPClient; kwargs...)
    println("Querying for files...")
    return client.py_client.files(;kwargs...)
end


"""
    download_file(client::ISIMIPClient, url::String; path::String=".")

Downloads a file using the Python client's download method.
"""
function download_file(client::ISIMIPClient, url::String; path::String=".")
    println("Downloading file via Python client...")
    # Call the download method on the Python object
    client.py_client.download(url, path=path)
end

end # end of ISIMIPClientPy module


#=
# Usage
using .ISIMIPClientPy

# Create a client instance. This will instantiate the Python client.
client = ISIMIPClient()

#climate_models = ["gfdl-esm4", "ukesm1-0-ll", "ipsl-cm6a-lr", "mpi-esm1-2-hr", "mri-esm2-0"]
climate_models = ["gfdl-esm4", "ukesm1-0-ll", "mpi-esm1-2-hr"]
scenarios = ["piControl", "historical", "ssp126", "ssp370", "ssp585"]
ocean_variables = ["thetao"]

response_files = files(client,
    simulation_round="ISIMIP3b",
    product=["InputData", "OutputData"],
    climate_forcing=climate_models,
    climate_scenario=scenarios,
    time_step = "monthly",
    region = "global",
    resolution = "60arcmin",
    climate_variable=ocean_variables,
    page_size=200000
)


results = response_files["results"]
paths = [g["path"] for g in results]
urls = [g["file_url"] for g in results] 
results[1]
ids = [g["specifiers"] for g in results]


df = DataFrame(
    climate_forcing = [i["climate_forcing"] for i in ids],
    climate_variable = [i["climate_variable"] for i in ids],
    climate_scenario = [i["climate_scenario"] for i in ids],
    time_step = [i["time_step"] for i in ids],
    size = [g["size"] for g in results]./(1*10^9),
    paths = [g["path"] for g in results],
    urls = [g["file_url"] for g in results] 
)

filter!(row -> any(!occursin.("-surf", row.paths)) | any(!occursin.("-bot", row.paths)), df)

# Define the base output folder
base_download_folder = "D:/met2map/ISIMIP/"

# 3. Loop through the DataFrame and download files to structured folders
println("\n--- Starting download from DataFrame ---")

if @isdefined(df) && !isempty(df)
    for (i, row) in enumerate(eachrow(df))
        # Construct the structured download path from the DataFrame columns
        download_path = joinpath(base_download_folder, row.climate_scenario, row.climate_forcing, row.climate_variable)
        
        # Get the URL for the current file
        file_url = row.urls

        println("\n($(i)/$(nrow(df))) Downloading to: ", download_path)
        download_file(client, file_url, path=download_path)
    end
else
    println("DataFrame `df` is not defined or is empty. No files to download.")
end

=#