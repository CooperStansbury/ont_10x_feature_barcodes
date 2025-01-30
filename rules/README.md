# Workflow Overview

## `gather.smk`
This Snakemake workflow manages:
- Indexing a reference genome and annotations.
- Preparing input FASTQ files.
- Setting up configuration files.


## `pipeline-core.smk`
This workflow handles core pipeline processes, including:
- **`demux_reads`**: Demultiplexes reads based on hash sequences using `nanoplexer`. 
  - Uses a reference hash sequence FASTA file.
  - Reads input FASTQ files and applies sequence constraints.
  - Outputs demultiplexing reports and organized hashed reads.
