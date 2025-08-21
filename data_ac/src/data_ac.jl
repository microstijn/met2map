module data_ac
    include("ISIMIP_client_wrapper.jl")
    using .ISIMIPClientPy
    export ISIMIPClient, datasets, files, download_file
    include("TaraBiosampleParser.jl")
    using .TaraBiosampleParser
    export parse_tara_metadata 
    export coalesce_case_insensitive_cols
end # module data_ac

