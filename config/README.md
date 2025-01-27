# Pipeline Configuration

This directory contains configuration files for setting up and running a Snakemake pipeline. These files define essential parameters, input/output paths, and execution settings for different stages of the workflow.

## Overview

The following configuration files are included:

-   **`config.yaml`** – Main configuration file specifying pipeline parameters, input/output locations, and reference genome details.
-   **`fastq_paths.txt`** – Lists sample IDs and their corresponding FASTQ file paths for processing.

## Configuration Details

The `config.yaml` file includes settings for:

**General Settings:**

-   **`threads`**: The number of threads to use for parallel execution of pipeline steps (default: 36).
-   **`output_path`**: The main directory where pipeline outputs will be stored (default: `/scratch/indikar_root/indikar1/shared_data/ont_10x_pipeline_test/`).
