#!/bin/bash

#SBATCH --account=indikar99
#SBATCH --partition=standard
#SBATCH --mail-user=cstansbu@umich.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=18
#SBATCH --mem=180G
#SBATCH --time=36:00:00

# Default values
CORES=18

# Print argument values nicely
echo "---------------------------------"
echo "  Snakemake Workflow Settings"
echo "---------------------------------"
echo "Config File: ${CONFIG}"
echo "Number of Cores: ${CORES}"
echo "---------------------------------"

## build the workflow from the most current snakefile
cp Snakefile workflow.smk

# Timestamp for logs
timestamp=$(date +"%Y%m%d_%H%M%S")

# Logging
log_dir="logs"
mkdir -p ${log_dir}
log_file="${log_dir}/snakemake_${timestamp}.log"

# DAG visualization
dag_file="${log_dir}/dag_${timestamp}.pdf"
snakemake --dag -s workflow.smk | dot -Tpdf > ${dag_file}

# Rulegraph (optional)
rulegraph_file="${log_dir}/rulegraph_${timestamp}.pdf"
snakemake --rulegraph -s workflow.smk | dot -Tpdf > ${rulegraph_file}

# HTML report (optional but recommended)
report_file="${log_dir}/report_${timestamp}.html"
snakemake --report ${report_file} -s workflow.smk

# Run Snakemake with logging
snakemake --use-conda --cores ${CORES} \
    --rerun-incomplete --latency-wait 90 --verbose \
    -s workflow.smk &> ${log_file}

