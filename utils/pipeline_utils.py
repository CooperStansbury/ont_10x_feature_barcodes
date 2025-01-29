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


HEADER_STR = "#" * 20


def log(message):
    """Prints a timestamped message to the console."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{timestamp} - {message}")


def get_output_filenames(input_df, extension, output_path):
  """Generates output filenames for processed data.

  Constructs output filenames by combining sample IDs from an input DataFrame 
  with a specified file extension and output directory path. The function 
  expects the input DataFrame to have a 'sample_id' column.

  Args:
    input_df: A pandas DataFrame with a 'sample_id' column.
    extension: The desired file extension for output files (e.g., '.txt', '.csv').
    output_path: The directory where output files will be written.

  Returns:
    A list of complete output filenames (including the output path and extension).
  """
  output_names = input_df['sample_id'].to_list()
  output_names = [f"{output_path}fastq/{x}.fastq{extension}" for x in output_names]
  return output_names


def get_fasta_sequence_names(fasta_file):
    """
    Loads sequence names from a FASTA file without external dependencies.
    
    Args:
    fasta_file: Path to the FASTA file.
    
    Returns:
    A list of sequence names.
    """
    sequence_names = []
    with open(fasta_file, "r") as f:
        for line in f:
          if line.startswith(">"):  # FASTA headers start with ">"
            sequence_names.append(line[1:].strip())  # Remove ">" and whitespace
    return sequence_names