


using Pkg
Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using met2map



using .GEMProcessor



convert_xml_to_sbml()
