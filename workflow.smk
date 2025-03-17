import os
import sys
import glob
import re
from datetime import datetime
from pathlib import Path
import pandas as pd
import yaml
import json
import tabulate

""" PATH CONFIG """
BASE_DIRECTORY = Path(workflow.basedir)

# config details
CONFIG_PATH = "/config/config.yaml"
CONFIG_BASENAME = os.path.basename(CONFIG_PATH)
CONFIG_ABS_PATH = str(BASE_DIRECTORY) + CONFIG_PATH
configfile: CONFIG_ABS_PATH 

# pipeline utilities
UTILS_PATH = "/utils/"
sys.path.append(str(BASE_DIRECTORY) + UTILS_PATH) 
import pipeline_utils as pu

""" PRINT THE EXECUTION DETAILS """
print(f"\n{pu.HEADER_STR} EXECUTION DETAILS {pu.HEADER_STR}")
pu.log(f"Pipeline started")
print(f"Base directory: {BASE_DIRECTORY}")
print(f"Config file path: {CONFIG_ABS_PATH}")

# Print config values
print(f"\n{pu.HEADER_STR} CONFIG DETAILS {pu.HEADER_STR}")
print(json.dumps(config, indent=4)) 

""" HELPER VARIABLES """
OUTPUT_PATH = config['output_path']

""" LOAD INPUTS """
INPUT_ABS_PATH = os.path.abspath(config['inputs']['fastq_file_paths'])
INPUT_BASENAME = os.path.basename(INPUT_ABS_PATH)
input_df = pd.read_csv(INPUT_ABS_PATH, comment="#")
samples = input_df['sample_id'].to_list()

# load the hash_sequences
seqs = pu.get_fasta_sequence_names(config['inputs']['hash_sequences'])

# get new path names
input_file_paths = input_df['file_path'].to_list()

if config['inputs']['gzipped']:
    extension = ".gz"
else:
    extension = ""

output_file_paths = pu.get_output_filenames(input_df, extension, OUTPUT_PATH)

print(f"\n{pu.HEADER_STR} INPUT FILES {pu.HEADER_STR}")
for _, row in input_df.iterrows():
    fbasename = os.path.basename(row['file_path'])
    print(f"{row['sample_id']}: {fbasename} ({row['file_path']})")


""" CHECKPOINTING """

def make_flexiplex_output(wildcards):
    """
    creates outputs based the sequence names
    """
    seqs = [line.strip() for line in open(checkpoints.get_seq_names.get().output.seqs)]
    return expand(OUTPUT_PATH + "flexiplex/{sid}_{fbc}.fastq",  sid=samples, fbc=seqs)


""" RULE FILES """
include: "rules/gather.smk"
include: "rules/pipeline-core.smk"


rule all:
    input:
        OUTPUT_PATH + "config/" + CONFIG_BASENAME,
        OUTPUT_PATH + "config/" + INPUT_BASENAME,
        OUTPUT_PATH + "whitelist/barcode_translation.txt",
        OUTPUT_PATH + "reference/hash_sequences.fasta",
        OUTPUT_PATH + "whitelist/detected_barcodes.txt",
        OUTPUT_PATH + "reference/hash_sequence_names.txt",
        OUTPUT_PATH + "whitelist/detected_barcodes_translation.txt",
        OUTPUT_PATH + "whitelist/detected_translated_barcodes.txt",
        output_file_paths,
        expand(OUTPUT_PATH + "reports/nanoplexer/{sid}_hashing_report.txt", sid=samples),
        expand(OUTPUT_PATH + "flexiplex/{sid}_{fbc}.fastq",  sid=samples, fbc=seqs),
        OUTPUT_PATH + "feature_barcodes/feature_barcodes.csv",
        OUTPUT_PATH + "feature_barcodes/fbc_map.csv",
    wildcard_constraints:
        sid="|".join(samples),
        fbc="|".join(seqs),

     

