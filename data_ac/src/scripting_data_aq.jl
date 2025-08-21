

#-----------------------------------------
# preamble & packages
#-----------------------------------------
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using data_ac
using JSON
using DataFrames
using CSV

#-----------------------------------------
# Parsing JSON biosamples
#-----------------------------------------

# locate file
metadata_filepath = "D:/met2map/PRJEB7988_biosamples/PRJEB7988_metadata.json"

# Run the parsing function
final_env_df = parse_tara_metadata(metadata_filepath)

# clean parsed df
coalesced_df = coalesce_case_insensitive_cols(final_env_df)

# write to file
mkpath("D:/met2map/PRJEB7988_metadata/")

CSV.write(
    "D:/met2map/PRJEB7988_metadata/PRJEB7988_metadata.tsv",
    coalesced_df,
    delim = "\t"
)

#-----------------------------------------
# Parsing JSON biosamples
#-----------------------------------------

