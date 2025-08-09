


using Pkg
Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using met2map

url = "https://doi.pangaea.de/10.1594/PANGAEA.875582?format=zip"
out = joinpath([@__DIR__, "..", "output"])

download_data(url, out, create_subfolder = "pang")


