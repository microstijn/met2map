
using Pkg
#Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using met2map
using Logging
using .Threads
using JSON
using CSV
using DataFrames

# ensure smbl structure of GEMs

indir = "D:/met2map/metage2metabo_TARA/p1/GEMs/"
outdir = "D:/met2map/metage2metabo_TARA/p1/GEMs_smbl/"

global_logger(NullLogger())

Threads.@threads for file in readdir(indir, join=true)
    convert_xml_to_sbml(file, outdir) # Call your function
end

# we now need to convert the folder structure to prepare for 
# metage2metabo

sort_sbml_files(
    outdir
)

project_dir = "D:/met2map"
metabolites_files = ["seeds/seeds.txt", "targets/targets.txt"]
output_dir = dirname.(metabolites_files)

# generate some seed base files
target_metabolites = [
    "M_bspa_e"     # Bisphenol A from Polycarbonate
]

seawater_seed_metabolites = [
    # Core Components
    "M_h2o_e", "M_h_e", "M_o2_e", "M_co2_e",
    # Major Nutrients
    "M_no3_e", "M_nh4_e", "M_pi_e", "M_so4_e",
    # Major Ions (Salts)
    "M_na1_e", "M_cl_e", "M_mg2_e", "M_ca2_e", "M_k_e",
    # Essential Trace Metals
    "M_fe3_e", "M_fe2_e", "M_zn2_e", "M_mn2_e", "M_cu2_e", "M_cobalt2_e",
    # Internal Currency Metabolites
    "M_atp_c", "M_adp_c", "M_amp_c", "M_nad_c", "M_nadh_c",
    "M_nadp_c", "M_nadph_c", "M_coa_c", "M_ppi_c"
]

seed_target = [target_metabolites, seawater_seed_metabolites]

for (output, metabolite) in zip(normpath.(joinpath.(project_dir, metabolites_files)), seed_target)
    generate_metabolite_list(
        metabolite,
        output
    )
end


# lets try metage2metabo
# first, generate a seed. 

for (met, out) in zip(metabolites_files, output_dir)
    create_seed_file(
        project_dir,
        String(met),
        out
    )
end



# run metacom
project_dir = "D:/met2map"
sample_dirs = readdir("D:/met2map/metage2metabo_TARA/p1/GEMs_smbl/", join = true)
sample_dirs = replace.(sample_dirs, project_dir => "")
results_dir = "metage2metabo_TARA/p1/metacom_results"
seeds_file = "seeds/seeds.sbml"
targets_file = "targets/seeds.sbml"

s = joinpath(project_dir, sample_dirs[1])

for sample in sample_dirs[1:20]
    execute_metacom(
        project_dir,
        sample,
        results_dir,
        seeds_file,
        targets_file;
        m2m_threads=7 # Optional: Override the default number of threads.
    )
end

#----------------------------
# Now that we have run metacom a fair amount
# we need to look how to process the output. 
#----------------------------



p = normpath.(readdir(joinpath.(project_dir, results_dir), join = true))

p = raw"D:\met2map\metage2metabo_TARA\p1\metacom_results\ERR1701760\community_analysis\contributions_of_microbes.json"
p = normpath(p)

data = JSON.parsefile(p)

keys(data)

function aggregate_metabolite_production(root_dir::String)
    # Find all 'rev_cscope.tsv' files recursively
    all_tsv_files = []
    for (current_path, dirs, files) in walkdir(root_dir)
        for file in files
            if file == "rev_cscope.tsv"
                push!(all_tsv_files, joinpath(current_path, file))
            end
        end
    end

    if isempty(all_tsv_files)
        @warn "No 'rev_cscope.tsv' files found in the directory: $root_dir"
        return DataFrame()
    end

    println("Found $(length(all_tsv_files)) files to process.")

    # 2. Process each file and store its summary DataFrame in a list
    all_sample_dfs = DataFrame[]
    for filepath in all_tsv_files
        try
            # The sample ID is the name of the folder TWO levels up
            sample_id = basename(dirname(dirname(filepath)))
            println("Processing sample: $sample_id")

            # Read the TSV file
            df = CSV.read(filepath, DataFrame)

            # The first column contains bin names, the rest are metabolites
            metabolite_cols = names(df)[2:end]
            
            # Calculate the sum for each metabolite column
            production_counts = [sum(df[!, col]) for col in metabolite_cols]

            # **FIX 2**: Create the DataFrame using the correct Pair syntax
            sample_df = DataFrame(
                :Metabolite => metabolite_cols,
                Symbol(sample_id) => production_counts
            )
            push!(all_sample_dfs, sample_df)

        catch e
            @error "Could not process file: $filepath"
            @error "  Error: " e
        end
    end

    # 3. Merge all individual sample DataFrames into one large DataFrame
    if isempty(all_sample_dfs)
        return DataFrame()
    end

    # Start with the first DataFrame
    merged_df = first(all_sample_dfs)

    # Iteratively join the rest of the DataFrames
    for i in 2:length(all_sample_dfs)
        merged_df = outerjoin(merged_df, all_sample_dfs[i], on = :Metabolite)
    end

    # 4. Clean up the final DataFrame
    # Replace any 'missing' values with 0, as this means the metabolite
    # was not present in that sample's file (i.e., 0 producers).
    for col in names(merged_df)
        if eltype(merged_df[!, col]) >: Missing
            merged_df[!, col] = coalesce.(merged_df[!, col], 0)
        end
    end
    
    println("\nProcessing complete!")
    return merged_df
end

results_directory = "D:/met2map/metage2metabo_TARA/p1/metacom_results"

# Run the analysis
final_summary_df = aggregate_metabolite_production(results_directory)

sort!(
    final_summary_df, :Metabolite
)

