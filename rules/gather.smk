# This Snakemake workflow manages indexing a reference genome and annotations,
# prepares input FASTQ files, and sets up configuration files.


rule get_config:
    """
    Copies the configuration file to the output directory.

    This rule takes the configuration file specified by `CONFIG_ABS_PATH`
    and copies it to the `config/` directory in the output location.
    """
    input:
        CONFIG_ABS_PATH
    output:
        OUTPUT_PATH + "config/" + CONFIG_BASENAME,
    shell:
        """ cp {input} {output} """


rule get_input_list:
    """
    Copies the input file list to the output directory.

    This rule takes the input file list specified by `INPUT_ABS_PATH`
    and copies it to the `config/` directory in the output location. 
    This list likely contains information about the FASTQ files 
    to be processed.
    """
    input:
        INPUT_ABS_PATH
    output:
        OUTPUT_PATH + "config/" + INPUT_BASENAME,
    shell:
        """ cp {input} {output} """


rule get_fastq_files:
    """
    Processes FASTQ files based on the 'inputs_are_directories' parameter.

    If 'inputs_are_directories' (in config) is True, it merges FASTQ files 
    from each input directory into a single output file. 
    Otherwise, it copies individual FASTQ files.
    """
    input:
        input_file_paths
    output:
        output_file_paths
    params:
        is_directory=config['inputs']['inputs_are_directories']
    run:
        import os
        import subprocess
        from shutil import copyfile
        import glob

        if params.is_directory:
            for i, dir_path in enumerate(input):
                out_path = output[i]
                # Use glob to get all .fastq or .fq files, adjust pattern as needed
                fastq_files = sorted(glob.glob(os.path.join(dir_path, "*.fastq*")))

                if not fastq_files:
                    print(f"Warning: No fastq files found in directory: {dir_path}")
                    # Create an empty file
                    open(out_path, 'w').close()
                    continue

                # Use cat for all files (no special handling for .gz)
                subprocess.run(f"cat {' '.join(fastq_files)} > {out_path}", shell=True, check=True)

        else:
            for i, in_path in enumerate(input):
                out_path = output[i]
                copyfile(in_path, out_path)


rule get_translation:
    """Copy barcode translation file from the configuration file to the output directory."""
    input:
        config['inputs']['barcode_translation'],
    output:
        OUTPUT_PATH + "whitelist/barcode_translation.txt",
    shell:
        """cp {input} {output}"""



rule get_detected_barcodes:
    """Copy barcode translation file from the configuration file to the output directory."""
    input:
        config['inputs']['detected_barcodes'],
    output:
        OUTPUT_PATH + "whitelist/detected_barcodes.txt",
    shell:
        """cp {input} {output}"""



rule extract_barcodes:
    """
    This rule extracts rows from a data file where the first column matches 
    a barcode in a separate barcode list using grep.
    """
    input:
        barcodes=OUTPUT_PATH + "whitelist/barcode_translation.txt",
        data=OUTPUT_PATH + "whitelist/detected_barcodes.txt",
    output:
        OUTPUT_PATH + "whitelist/detected_barcodes_translation.txt"
    shell:
        """ 
        awk 'NR==FNR {{terms[$1]; next}} $1 in terms {{print $1, $2; delete terms[$1]}}' {input.data} {input.barcodes} > {output}
        """


rule split_columns:
    """
    Splits a two-column text file into two separate files, one for each column.
    """
    input:
        OUTPUT_PATH + "whitelist/detected_barcodes_translation.txt",
    output:
        OUTPUT_PATH + "whitelist/detected_translated_barcodes.txt",
    shell:
        """
        awk '{{print $2}}' {input} > {output}
        """


rule get_hashing_seqs:
    """Copy hash sequences from the configuration file to the output directory."""
    input:
        config['inputs']['hash_sequences'],
    output:
        OUTPUT_PATH + "reference/hash_sequences.fasta",
    shell:
        """cp {input} {output}"""


checkpoint get_seq_names:
    """Extract sequence names from the hash sequences FASTA file."""
    input:
        OUTPUT_PATH + "reference/hash_sequences.fasta"
    output:
        seqs=OUTPUT_PATH + "reference/hash_sequence_names.txt"
    shell:
        """
        grep '>' {input} | sed 's/>//' > {output.seqs}
        """


rule make_barcode_fasta:
    """
    Generate a FASTA file from a barcode translation table.

    This rule takes a text file with barcode IDs and sequences as input
    and creates a FASTA file where each barcode sequence is represented
    as a separate entry.
    """
    input:
        OUTPUT_PATH + "whitelist/barcode_translation.txt"
    output:
        OUTPUT_PATH + 'reference/barcodes.fasta'
    shell:
        """
        awk '{{print ">"$1":"$2"\\n"$2}}' {input} > {output}
        """
