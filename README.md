# Project: met2map 

TARA Oceans and ISIMIP Integration

This repository contains the code and resources for a proof-of-principle project to combine marine metagenomic data from the TARA Oceans expedition with environmental model outputs from the Inter-Sectoral Impact Model Intercomparison Project (ISIMIP).

The primary goal is to demonstrate a workflow for integrating these two distinct datasets to investigate potential relationships between marine microbial communities and large-scale climate variables.

## Project Goals

* **Integrate Data:** Combine location-specific TARA Oceans data with corresponding ISIMIP model outputs.
* **Analyze Correlations:** Explore statistical relationships between microbial community composition and environmental parameters from the models.
* **Proof-of-Principle:** Develop a repeatable, well-documented workflow that can be scaled for further research.

***

## Project Checklist

The following is a checklist of tasks to complete this project.

### **Phase 1: Repository Setup & Planning**

* [x] Initialize Git repository and create an initial commit.
* [x] Write a preliminary `README.md` outlining the project's goal and methodology.
* [x] Create a `LICENSE` file.
* [x] Define a clear folder structure for code, data, and outputs.
* [x] Set up a virtual environment or `Project.toml` file for Julia dependencies.

### **Phase 2: Data Acquisition & Processing**
**generic helper functions**

* [x] Write generic helper functions for downloading data. 

**TARA Oceans Data**

* [ ] Identify which Tara Oceans datasets are required.
* [ ] Locate and list all direct download URLs for required data.
* [ ] Develop a script to process and clean the raw Tara data.

**ISIMIP Model Data**

* [ ] Identify the most relevant ISIMIP model outputs and inputs.
* [ ] Download the selected ISIMIP climate model outputs.
* [ ] Develop a Julia script map both datasets on a common raster. 

### **Phase 3: Integration & Analysis**

* [ ] Create script to load and merge the processed data.
* [ ] Develop ML methodology to predict the datasets.
* [ ] Develop proper statistics.
* [ ] Create visualizations to illustrate the proof of principle.

***

### **Project Data Acquisition**

This document outlines the procedures for downloading the project's metadata, raw metagenomic sequence data, and gene catalogs from the TARA Ocean project.

---

#### **1. BioSample Metadata (Project PRJEB7988)**

To understand the project's scope and sample details, BioSample metadata was first downloaded from the NCBI.

* **Tool Installation**: The NCBI Datasets command-line tool was installed via conda.
    ```bash
    conda install -c conda-forge ncbi-datasets-cli
    ```
* **Download Command**: A complete JSON data report for the project was downloaded using the `datasets summary` command.
    ```bash
    # Create a directory for the output
    mkdir -p data/metadata

    # Download the project metadata summary
    datasets summary bioproject PRJEB7988 > data/metadata/PRJEB7988_metadata.json
    ```
* **Output File**: The command generates a single JSON file (`PRJEB7988_metadata.json`) containing a structured report with rich BioSample metadata (e.g., collection date, host, isolation source) for each sample in the project.

---

#### **2. Metagenomic Sequence Data (Project ERP009009)**

The raw metagenomic sequence reads were sourced directly from the European Nucleotide Archive (ENA).

* **Dataset**: TARA Ocean metagenomic datasets, available under ENA study accession **ERP009009**. You can browse the project here: [https://www.ebi.ac.uk/ena/browser/view/ERP009009](https://www.ebi.ac.uk/ena/browser/view/ERP009009)
* **Download Method**: The data files were downloaded by running the `wget` shell script provided directly by the ENA repository for the project.
* **Execution Environment**: To ensure compatibility with the Linux-based shell script, Git Bash for Windows was used to execute the download commands.

---

#### **3. TARA Ocean Gene Catalogs (GEMS)**

The TARA Oceans prokaryotic gene catalogs (GEMS) were downloaded from Zenodo to provide a reference for functional analysis.

* **Datasets**: The specific datasets used are:
    * TARA Oceans prokaryotic genome and metagenome-assembled genome GEMS: [https://zenodo.org/records/5597227](https://zenodo.org/records/5597227)
    * TARA Oceans virome GEMS: [https://zenodo.org/records/5599412](https://zenodo.org/records/5599412)
* **Tool Installation**: The `zenodo-get` command-line tool was installed via pip.
    ```bash
    pip install zenodo-get
    ```
* **Download Command**: The gene catalogs were downloaded using their Zenodo record identifiers.
    ```bash
    # Create a directory for the gene catalogs
    mkdir -p data/gems

    # Download the TARA Oceans GEMS catalogs
    zenodo-get 10.5281/zenodo.5597227 -o data/gems/
    zenodo-get 10.5281/zenodo.5599412 -o data/gems/
    ```

## Getting Started

To get a local copy up and running, follow these simple steps.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```

2.  **Install dependencies:**
    (Instructions will be added here once a dependency manager like `Project.toml` is set up.)

3.  **Run the analysis:**
    (Instructions for running the main script will be added here.)

***

## Contributing

Contributions are welcome but not required in such an early phase. 
