# --- Julia Module to Run m2m metacom on a Single Sample ---

module MetacomRunner

export execute_metacom, create_seed_file, generate_metabolite_list

"""
    generate_metabolite_list(metabolite_ids::Vector{String}, output_path::String)

Writes a vector of metabolite ID strings to a text file, with one ID per line.
This file can then be used as input for the `create_seed_file` function.

# Arguments
- `metabolite_ids::Vector{String}`: A Julia vector containing the metabolite IDs.
- `output_path::String`: The full path where the output text file will be saved.
"""
function generate_metabolite_list(metabolite_ids::Vector{String}, output_path::String)
    println("Generating metabolite list file at: $output_path")
    try
        # Ensure the directory for the file exists
        mkpath(dirname(output_path))
        
        # Open the file in write mode and write each ID on a new line
        open(output_path, "w") do io
            for id in metabolite_ids
                println(io, id)
            end
        end
        println("Successfully generated file.")
    catch e
        @error "Failed to generate metabolite list file."
        @error "  Error: " e
    end
end


"""
    create_seed_file(host_project_dir, metabolites_file_relative, output_dir_relative; <keyword arguments>)

Automates running the `m2m seeds` Docker command to create an SBML seed/target file.

# Arguments
- `host_project_dir::String`: The absolute path to the main project folder on the host machine.
- `metabolites_file_relative::String`: The path to the input text file with metabolite IDs, relative to `host_project_dir`.
- `output_dir_relative::String`: The path where the output SBML file will be saved, relative to `host_project_dir`.

# Keyword Arguments
- `docker_image::String="m2m"`: The name of the Docker image to use.
- `container_mount_point::String="/data"`: The path where the project folder will be mounted inside the container.
"""
function create_seed_file(
    host_project_dir::String,
    metabolites_file_relative::String,
    output_dir_relative::String;
    docker_image::String="m2m",
    container_mount_point::String="/data"
)
    # --- Path setup ---
    host_metabolites_path = joinpath(host_project_dir, metabolites_file_relative)
    host_output_dir = joinpath(host_project_dir, output_dir_relative)

    # --- Convert paths for Docker ---
    to_docker_path(p) = replace(p, "\\" => "/")
    container_metabolites_path = to_docker_path(joinpath(container_mount_point, metabolites_file_relative))
    container_output_path = to_docker_path(joinpath(container_mount_point, output_dir_relative))

    # --- Validation ---
    if !isfile(host_metabolites_path)
        @error "Metabolites file not found: $host_metabolites_path"
        return
    end
    mkpath(host_output_dir)

    println("Generating SBML file from '$(basename(host_metabolites_path))'...")

    # Construct the full docker command
    cmd = `docker run --rm -v $host_project_dir:$container_mount_point $docker_image m2m seeds --metabolites $container_metabolites_path -o $container_output_path`

    try
        run(cmd)
        println("Successfully created SBML file in '$output_dir_relative'")
    catch e
        @error "Failed to create SBML file."
        @error "  Error: " e
    end
end

"""
    execute_metacom(host_project_dir, sample_dir_relative, output_dir_relative, seeds_file_relative, targets_file_relative; <keyword arguments>)

Automates running the `m2m metacom` Docker command on a single sample directory.

# Arguments
- `host_project_dir::String`: The absolute path to the main project folder on the host machine.
- `sample_dir_relative::String`: The path to the specific sample folder to process, relative to `host_project_dir`.
- `output_dir_relative::String`: The path where the result folder for this sample will be created, relative to `host_project_dir`.
- `seeds_file_relative::String`: The path to the seeds file, relative to `host_project_dir`.
- `targets_file_relative::String`: The path to the targets file, relative to `host_project_dir`.

# Keyword Arguments
- `docker_image::String="m2m"`: The name of the Docker image to use.
- `container_mount_point::String="/data"`: The path where the project folder will be mounted inside the container.
- `m2m_threads::Int=2`: The number of threads for the `m2m` tool to use inside the container (0 means all available cores).
"""
function execute_metacom(
    host_project_dir::String,
    sample_dir_relative::String,
    output_dir_relative::String,
    seeds_file_relative::String,
    targets_file_relative::String;
    docker_image::String="m2m",
    container_mount_point::String="/data",
    m2m_threads::Int=2
)
    # --- Path setup ---
    host_sample_dir = joinpath(host_project_dir, sample_dir_relative)
    host_output_dir = joinpath(host_project_dir, output_dir_relative)
    sample_id = basename(host_sample_dir)
    
    # --- Convert paths for Docker ---
    # This function ensures all paths use forward slashes, which is required
    # by the Linux environment inside the Docker container.
    to_docker_path(p) = replace(p, "\\" => "/")

    # Translate host paths to paths inside the container
    container_seeds_path = to_docker_path(joinpath(container_mount_point, seeds_file_relative))
    container_targets_path = to_docker_path(joinpath(container_mount_point, targets_file_relative))
    container_sample_path = to_docker_path(joinpath(container_mount_point, sample_dir_relative))
    container_sample_output_path = to_docker_path(joinpath(container_mount_point, output_dir_relative, sample_id))

    # --- Validation ---
    if !isdir(host_sample_dir)
        @error "Sample directory not found: $host_sample_dir"
        return
    end
    
    # Create the specific output directory for this sample
    mkpath(joinpath(host_output_dir, sample_id)) 

    println("Starting sample '$sample_id'...")

    # Construct the full docker command
    cmd = `docker run --rm -v $host_project_dir:$container_mount_point $docker_image m2m metacom -o $container_sample_output_path -s $container_seeds_path -t $container_targets_path -c $m2m_threads -n $container_sample_path`
    
    try
        run(cmd)
        println("Successfully finished sample '$sample_id'")
    catch e
        @error "Failed to process sample '$sample_id'."
        @error "  Error: " e
    end
end

end # module MetacomRunner
