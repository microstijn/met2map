
using Pkg
#Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using met2map
using Logging
using .Threads

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



