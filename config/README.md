# Pipeline Configuration

This directory contains configuration files for setting up and running a Snakemake pipeline. These files define essential parameters, input/output paths, and execution settings for different stages of the workflow.

## Overview

The following configuration files are included:

- **`config.yaml`** – Main configuration file specifying pipeline parameters, input/output locations, and hashing settings.
- **`fastq_paths.txt`** – Lists sample IDs and their corresponding FASTQ file paths for processing.
- **`hash_sequences.fasta`** – Contains the hash sequences used for barcode assignment.

## Configuration Details

### General Settings

- **`threads`**: The number of threads to use for parallel execution of pipeline steps (default: `36`).
- **`output_path`**: The main directory where pipeline outputs will be stored (default: `"/scratch/indikar_root/indikar1/shared_data/fbc_test/"`).

### Input Files

- **`fastq_file_paths`**: Specifies the location of a text file (`config/fastq_paths.txt`) containing paths to FASTQ files.
- **`inputs_are_directories`**: Boolean flag indicating whether the input paths are directories (`true`).
- **`gzipped`**: Indicates whether the input FASTQ files are gzipped (`true`).
- **`barcode_translation`**: Path to a barcode translation file (`"/nfs/turbo/umms-indikar/shared/projects/cell_cycle/data/10x_barcode_lists/3M-3pgex-may-2023_translation.txt"`).
- **`detected_barcodes`**: Path to the file containing detected barcodes (`"/scratch/indikar_root/indikar1/shared_data/pipeline_test/whitelist/detected_barcodes.txt"`).
- **`hash_sequences`**: Path to the FASTA file containing hash sequences (`config/hash_sequences.fasta`).

### Hashing Parameters

- **`expected_cells`**: The expected number of cells in the dataset (`10000`).
- **`min_length`**: The minimum length of reads to be considered (`100`).
- **`max_length`**: The maximum length of reads to be considered (`250`).
- **`nanoplexer_args`**: Command-line arguments for the Nanoplexer tool (`"-L 150 -m 2 -x 2 -o 3 -e 1"`).
- **`flexiplex_args`**: Command-line arguments for the Flexiplex tool (`"-e 2 -x '' -b ???????????????? -u '' -x ''"`).

This configuration file ensures that the pipeline runs efficiently with appropriate resource allocation and input parameters. Modify these settings as needed to adapt the workflow to different datasets and computing environments.
