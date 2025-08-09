


using Pkg
Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.activate(joinpath(@__DIR__, ".."))
using Revise
using met2map

url = "https://doi.pangaea.de/10.1594/PANGAEA.875582?format=zip"
ouf = "D:/met2map"
out = joinpath([ouf, "output/metagenomes/wget/"])

f = "D:/met2map/metagenomes/wget/ena-file-download-analysis-ERP009009-submitted_ftp-20250809-1859.sh"

download_data(url, out, create_subfolder = "pang")

execute_commands_from_file(f)
