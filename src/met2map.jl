module met2map
    include("GEMProcessor.jl")
    using .GEMProcessor
    export convert_xml_to_sbml
    include("FileSorter.jl")
    using .FileSorter
    export sort_sbml_files
end # module met2map

