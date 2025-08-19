


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
