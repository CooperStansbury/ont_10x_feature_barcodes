# Conda Environments

This directory contains YAML files to set up the Conda environments needed for the pipeline.

## Environments

- **`workflow-env.yaml`** – **Required:** Install this manually to run Snakemake.
- **`pipeline-core.yaml`** – Managed by Snakemake; no manual setup needed.

**Note:** Snakemake automatically creates and manages all environments except `workflow-env.yaml`. When you run the pipeline, Snakemake will build any required environments based on the corresponding YAML files.

## Setup

Create the required environment before running the pipeline:

```bash
conda env create -f workflow-env.yaml
