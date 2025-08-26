using Pkg
#Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.activate(joinpath(@__DIR__, ".."))


# ------------------------------------------
# Plotting and data packages
# ------------------------]-----------------

using DataFrames
using CairoMakie
using CSV
using Clustering
using Distances
using ColorSchemes
using MultivariateStats

# ------------------------------------------
# load data
# ------------------------------------------

p = "D:/met2map/metage2metabo_TARA/p1/metacom_results/metacom_analysis/aggregate_metabolite_production.tsv"

df = CSV.File(p) |> DataFrame

# ------------------------------------------
# plot data
# ------------------------------------------

# 1. Prepare data for clustering
metabolite_labels = df[!, :Metabolite]
data_matrix = Matrix(df[!, 2:end])
# 2. Calculate the distance matrix between metabolites (rows)
dist_matrix = pairwise(Euclidean(), data_matrix, dims=1)
# 3. Perform hierarchical clustering using the distance matrix

hclust_result = hclust(dist_matrix, linkage=:ward)
# 4. Assign metabolites to clusters
optimal_order = hclust_result.order

data_matrix2 = Matrix(df[!, 2:end])'
# 2. Calculate the distance matrix between metabolites (rows)
dist_matrix2 = pairwise(Euclidean(), data_matrix2, dims=1)
hclust_result2 = hclust(dist_matrix2, linkage=:ward)
optimal_order2 = hclust_result2.order

mat_reordered = data_matrix[optimal_order, optimal_order2]

categories = [
    "Climate & Greenhouse Gases", "Climate & Greenhouse Gases", "Climate & Greenhouse Gases", "Climate & Greenhouse Gases",
    "Nutrient Cycling & Eutrophication", "Nutrient Cycling & Eutrophication", "Nutrient Cycling & Eutrophication",
    "Pollutant & Plastic Degradation", "Pollutant & Plastic Degradation", "Pollutant & Plastic Degradation"
]

metabolite_ids = [
    "M_ch4_e", "M_n2o_e", "M_h2s_e", "M_dms_e",
    "M_nh4_e", "M_no3_e", "M_pi_e",
    "M_trphth_e", "M_bspa_e", "M_tol_e"
]

metabolite_names = [
    "Methane", "Nitrous Oxide", "Hydrogen Sulfide", "Dimethyl Sulfide (DMS)",
    "Ammonia", "Nitrate", "Phosphate",
    "Terephthalic acid", "Bisphenol A", "Toluene / Benzene"
]

significance = [
    "Production indicates methanogenesis in anaerobic zones.",
    "Production signals incomplete denitrification, releasing a potent greenhouse gas.",
    "Production is a hallmark of anaerobic sulfate reduction and poor water quality.",
    "Production influences cloud formation and atmospheric chemistry.",
    "Production indicates nitrogen fixation and remineralization are active.",
    "Production signifies nitrification and potential to fuel algal blooms.",
    "Production indicates remineralization of a limiting nutrient.",
    "Production is direct evidence of PET plastic degradation.",
    "Production indicates breakdown of polycarbonate plastic or related pollutants.",
    "Production indicates degradation of crude oil components."
]

# Create the DataFrame
wq_targets_df = DataFrame(
    Category = categories,
    MetaboliteID = metabolite_ids,
    Name = metabolite_names,
    Significance = significance
)

pollutant_production_df = filter(
    row -> row.Metabolite in wq_targets_df.MetaboliteID,
    df
)

smalldf = pollutant_production_df[:, 2:end][:, optimal_order2]

df_reordered = df[:, 2:end][optimal_order, optimal_order2]
df_reordered.metabolite = df[:, :Metabolite][optimal_order]

pollutant_production_df = filter(
    row -> row.metabolite in wq_targets_df.MetaboliteID,
    df_reordered
)

# PCA parse_tara_metadata

Xtr = Matrix(mat_reordered[1:2:end,:])'
Xte = Matrix(mat_reordered[2:2:end,:])'

Xtr = Matrix(mat_reordered[:,1:2:end])
Xte = Matrix(mat_reordered[:,2:2:end])

M = fit(PCA, Xtr; maxoutdim=2)
Yte = predict(M, Xte)
Xr = reconstruct(M, Yte)

cmap = cgrad(:oxy)

begin
    f = Figure(
        #resolution = (1000, 500)
    )

    axA = Axis(
        f[1, 1],
        xlabel = "Metabolites",
        ylabel = "Ocean metabolic model" ,
        title = "Robust metabolite production\nas predicted by metabolic\nmodels",
        titlealign = :left,
        subtitle = "clustering: hclust"
    )

    x = pollutant_production_df.metabolite

    axB = Axis(
        f[1, 2],
        xticks = (1:length(x), string.(x)), 
        xticklabelrotation=45.0,
        title = "Metabolites of interest",
        titlealign = :left,
        subtitle = "clustering: hclust"
    )
#=
    axC = Axis(
        f[2, 1],
        title = "PCA of metabolite coverage",
        ylabel = "PCA dim 2",
        xlabel = "PCA dim 1",
        yticklabelsvisible=false,
        xticklabelsvisible=false
    )


    scatter!(
        axC,
        Yte[1,:],
        Yte[2,:],
        strokewidth = 1
    )
=#

    hm = heatmap!(
        axA,
        mat_reordered,
        colormap = cmap
    )
    
    hm2 = heatmap!(
        axB,
        Matrix(pollutant_production_df[:, 1:end-1]),
        colormap = cmap
    )


    Colorbar(
        f[1,3],
        hm2,
        label = "production support [#]"
    )

    f

end

plot_path = "D:/met2map/plot_folder/"

p = joinpath(plot_path, "inital.pdf")
save(p, f)