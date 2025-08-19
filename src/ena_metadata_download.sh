#!/bin/bash

# === CONFIGURATION ===
# The project ID you want to download samples for
PROJECT_ID="PRJEB7988"

# The directory where you want to save the files
OUTPUT_DIR="./${PROJECT_ID}_biosamples"
# =====================


# Check if jq is installed, as it's required for parsing the API response
if ! command -v jq &> /dev/null
then
    echo "Error: 'jq' is not installed. Please install it to run this script."
    echo "On Debian/Ubuntu: sudo apt-get install jq"
    echo "On macOS (Homebrew): brew install jq"
    echo "On Windows (with Chocolatey): choco install jq"
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Fetching a complete list of sample accessions for project $PROJECT_ID..."
echo "(This may take a moment for large projects...)"

# ENA Portal API URL to search for all sample accessions within the project.
# - We use the JSON format which is more robust for scripting.
# - limit=0 tells the API we want all results, avoiding manual pagination.
SEARCH_URL="https://www.ebi.ac.uk/ena/portal/api/search?result=sample&query=study_accession%3D%22${PROJECT_ID}%22&fields=sample_accession&format=json&limit=0"

# Use 'curl' to fetch the list and 'jq' to parse it.
# - The '.[] | .sample_accession' part extracts the accession value for each sample.
# - The 'read -r' command is safer for reading file paths and names.
# - We store the accessions in a Bash array to process them reliably.
mapfile -t accessions < <(curl -s "$SEARCH_URL" | jq -r '.[] | .sample_accession')

# Get the total count for progress reporting
total_count=${#accessions[@]}

if [ "$total_count" -eq 0 ]; then
    echo "No samples found for project $PROJECT_ID. Please check the project ID."
    exit 0
fi

echo "Found $total_count samples. Starting download..."

# --- Download Loop ---
count=0
for accession in "${accessions[@]}"; do
  count=$((count + 1))
  output_file="${OUTPUT_DIR}/${accession}.txt"
  
  # Print progress
  echo -ne "Downloading sample ${count} of ${total_count} (${accession})...\\r"
  
  # Check if the file already exists to avoid re-downloading
  if [ ! -s "$output_file" ]; then
    # Construct the direct download URL for the text format of the BioSample
    DOWNLOAD_URL="https://www.ebi.ac.uk/ena/browser/api/text/${accession}"
    
    # Use 'wget' to download the file.
    # - We've removed the quiet flag (-q) so errors are visible.
    # - We add a timeout in case the server hangs.
    wget --timeout=15 -O "$output_file" "$DOWNLOAD_URL" 2>/dev/null
    
    # Add a small delay to be kind to the ENA servers and avoid rate-limiting
    sleep 0.2
  fi
done

echo -e "\\n\\nDownload complete! ✨"
echo "All BioSample files have been saved in the '${OUTPUT_DIR}' directory."
