

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
# getting WorldOceanAtlas data with
#-----------------------------------------

options = get_woa_options()
output_dir = "D:/met2map/woa/"
year = 2018
variables = [i[1] for i in options.variables]
resolution = 1
climatology = [i[1] for i in options.climatologies]
period = collect(1:12)


fieldnames(WOAOptions)

status = []

for var in variables, clim in climatology, per in period
    stat = download_woa_data(
        output_dir  = output_dir,
        year        = year,
        v           = var,
        gr          = resolution,
        climatology = clim,
        period      = per
    );
    push!(
       status, stat 
    )
end

options = get_woa_options()
output_dir = "D:/met2map/woa/"
year = 2018
variables = [i[1] for i in options.variables]
resolution = 1
climatology = [i[1] for i in options.climatologies]
period = collect(1:12)


