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

## Data locations

**Metagenomes**
TARA Ocean metagenomic datasets (ENA accession: ERP009009 https://www.ebi.ac.uk/ena/browser/view/ERP009009) were downloaded by running the repository's provided wget shell script in Git Bash for Windows.

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
