
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using data_ac
using JSON
using DataFrames

# locate file
l = "D:/met2map/PRJEB7988_biosamples/PRJEB7988_metadata.json"

data = JSON.parsefile(l)

z = data["reports"][1]["assembly_info"]["biosample"]["attributes"]

println(z)

df = DataFrame()

for i in z
    df_t = DataFrame(i)
    append!(
        df, 
        df_t
    )
end




print(df.name)