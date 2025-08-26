module met2map
    include("GEMProcessor.jl")
    using .GEMProcessor
    export convert_xml_to_sbml
    include("FileSorter.jl")
    using .FileSorter
    export sort_sbml_files
    include("MetacomRunner.jl")
    using .MetacomRunner
    export execute_metacom
    export create_seed_file
    export generate_metabolite_list
    export aggregate_metabolite_production
end # module met2map

