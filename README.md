# ONT 10x Feature Barcoding Pipeline

This pipeline processes single-cell TSB libraries generated using Oxford Nanopore Technologies (ONT) sequencing with 10x Genomics GEM chips.

## Overview

The pipeline assumes that the sequencing library was prepared using 10x Genomics technology and is designed to handle the specific requirements of ONT single-cell transcriptomics data.

## Cloning the Pipeline Repository

To get started, first clone the pipeline repository from GitHub:

```bash
git clone https://github.com/CooperStansbury/ont_10x_feature_barcodes.git
cd ont_10x_feature_barcodes
```

This ensures you have the latest version of the pipeline.

## Running the Pipeline

To run the pipeline, follow these steps:

1.  **Set Up the Environment**  
    Ensure Conda is installed and set up correctly. The pipeline requires the following Conda environment:

    *   **Top-level environment:** `workflow-env.yaml`

    Install the environments by running:

    ```bash
    conda env create -f envs/workflow-env.yaml
    ```

    After installation, activate the top-level environment:

    ```bash
    conda activate workflow-env
    ```

2.  **Prepare Configuration Files**  
    Update the `config.yaml` file with the correct paths to your input data, reference genome, and output directories.

3.  **Execute the Pipeline**  
    Always run Snakemake using the `--use-conda` flag to ensure proper dependency management:

    ```bash
    snakemake --use-conda --cores <num_cores>
    ```

    Replace `<num_cores>` with the number of threads available for computation.

4.  **Dry Run (Optional)**  
    To verify the workflow without executing commands:

    ```bash
    snakemake --use-conda --configfile config.yaml -n
    ```

5.  **Cluster Execution (Optional)**  
    If running on an HPC system, submit jobs using:

    ```bash
    snakemake --use-conda --cluster "sbatch --mem={resources.mem_mb}" --jobs 10
    ```

## Input Requirements

*   **Raw FASTQ Files:** Path specified in `config.yaml` and organized in a `fastq_paths.txt` file as described in the config file's readme.
*   **Configuration File:** `config.yaml` contains parameters for alignment, filtering, and output directories.

## Output

This pipeline produces the following output files and directories:

- **`config`**: Stores the configuration files used for the pipeline run, ensuring reproducibility.
- **`fastq`**: Contains the initial raw FASTQ files used as input.
- **`feature_barcodes`**: Holds the disambiguated feature barcodes, likely in a structured format (e.g., CSV, TSV) with associated metadata.
- **`flexiplex`**: Contains intermediate files and results related to the Flexiplex barcode correction process. This might include:
  - Corrected barcode sequences.
  - Logs and reports from the Flexiplex tool.
  - Statistics on error correction.
- **`hashed_reads`**: Stores reads that have been hashed based on their assigned feature barcodes. This might be organized by:
  - **`test`**: A subdirectory potentially containing a subset of hashed reads for testing or validation purposes.
- **`reference`**: Contains reference files used in the pipeline, such as:
  - Genome sequences.
  - Annotation files (e.g., GTF).
  - Barcode whitelists.
- **`reports`**: Houses various reports generated during the pipeline execution:
  - **`nanoplexer`**: Reports related to the Nanoplexer demultiplexing step, including:
    - Demultiplexing statistics.
    - Barcode assignment summaries.
    - Potential error rates.
- **`whitelist`**: Contains the initial whitelist of expected feature barcodes, potentially used for filtering or validation.

## Troubleshooting

*   **Ensure Conda is installed and environments are set up correctly.**
*   **Verify input file paths:** Ensure all paths in `config.yaml` and `fastq_paths.txt` are correct.
*   **Check for missing dependencies:** Run `snakemake --use-conda --conda-create-envs-only`.
*   **Review logs:** Check the output logs in the `logs` directory for error messages and troubleshooting hints.

---

For further details and support, refer to the official Snakemake documentation:  
[https://snakemake.readthedocs.io](https://snakemake.readthedocs.io)