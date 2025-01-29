checkpoint demux_reads:
    """demultiplex reads based on hash sequences using nanoplexer"""
    input:
         fasta=OUTPUT_PATH + "reference/hash_sequences.fasta",
         fastq=OUTPUT_PATH + "fastq/{sid}.fastq" + extension,
    output:
         report=OUTPUT_PATH + "reports/nanoplexer/{sid}_hashing_report.txt",
         dir=directory(OUTPUT_PATH + "hashed_reads/{sid}/")
    conda:
        "../envs/pipeline-core.yaml"
    params:
        minlen=config['hashing']['min_length'],
        maxlen=config['hashing']['max_length'],
        nanoplexer_args=config['hashing']['nanoplexer_args']
    wildcard_constraints:
        sid="|".join(samples)
    threads:
         config['threads']
    shell:
        """seqkit seq -M {params.maxlen} -m {params.minlen} {input.fastq} | nanoplexer \
         -b {input.fasta} -t {threads} {params.nanoplexer_args} -p {output.dir} -l {output.report} - """


rule find_barcodes:
    """Extract reads containing known barcodes from a FASTQ file using flexiplex."""
    input:
        report=OUTPUT_PATH + "reports/nanoplexer/{sid}_hashing_report.txt",
        barcodes=OUTPUT_PATH + "whitelist/detected_translated_barcodes.txt",
    output:
        flag=touch(OUTPUT_PATH + "flexiplex/{sid}_{fbc}.done"),
        fastq=OUTPUT_PATH + "flexiplex/{sid}_{fbc}.fastq",
        report=OUTPUT_PATH + "flexiplex/{sid}_{fbc}_reads_barcodes.txt",
    conda:
        "../envs/pipeline-core.yaml"
    params:
        args=config['hashing']['flexiplex_args'],
        prefix=OUTPUT_PATH + "flexiplex/{sid}_{fbc}",
        fastq=OUTPUT_PATH + "hashed_reads/{sid}/{fbc}.fastq",
    threads:
         config['threads']
    wildcard_constraints:
        sid="|".join(samples)
    shell:
        """ flexiplex -p {threads} -n {params.prefix} {params.args} -k {input.barcodes} {params.fastq} > {output.fastq} """


rule compile_feature_barcodes:
    """
    Load and integrate and the flexiplex output for fbc resolution
    """
    input:
        whitelist=OUTPUT_PATH + "whitelist/detected_barcodes_translation.txt",
        flex=expand(OUTPUT_PATH + "flexiplex/{sid}_{fbc}_reads_barcodes.txt", sid=samples, fbc=seqs)
    output:
        OUTPUT_PATH + "feature_barcodes/feature_barcodes.csv",
    conda:
        "../envs/pipeline-core.yaml"
    wildcard_constraints:
        sid="|".join(samples),
        fbc="|".join(seqs),
    shell:
        """ python scripts/build_feature_barcode_map.py {input.whitelist} {output} {input.flex} """
    