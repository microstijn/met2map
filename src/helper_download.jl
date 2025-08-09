# This script reads a list of URLs from a file and downloads each one.

# 1. Define the path to your URL list file and the output directory.
script_dir = @__DIR__
using Pkg
Pkg.activate(joinpath(script_dir, ".."))
using Downloads
url_list_file = joinpath([dirname(@__DIR__), "download_locations","downloads.txt"])

output_dir = "tara_oceans_pangaea"


# 2. Create the output directory if it doesn't exist.
if !isdir(output_dir)
    mkdir(output_dir)
    println("Created directory: $output_dir")
end

# 3. Read the list of URLs from the file.
println("Reading URLs from $url_list_file...")
urls = readlines(url_list_file)

# 4. Iterate through the URLs and download each file.
for url in urls
    # Skip empty lines
    if isempty(url)
        continue
    end
    
    # Extract the filename from the URL, but then clean it.
    # We will use a more robust way to create a valid filename.
    filename = "Pangaea_875582_zipfile.zip"
    output_path = joinpath(output_dir, filename)

    println("Attempting to download: $filename")
    
    # Check if the file already exists
    if isfile(output_path)
        println("File '$filename' already exists. Skipping.")
        continue
    end

    try
        Downloads.download(url, output_path)
        println("Successfully downloaded '$filename'.")
    catch e
        println("Failed to download '$filename'. Error: ", e)
    end
end

println("All downloads processed.")