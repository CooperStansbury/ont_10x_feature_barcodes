rule gather_and_filter_hash_reads:
    input:
        config['hashing_read_dir'] + "{sample_id}.fastq.gz",
    output:
        OUTPUT + "hash_fastq/{sample_id}.fastq.gz",
    conda:
        "seqkit"
    params:
        minlen=100,
        maxlen=250,
    shell:
        "seqkit seq -M {params.maxlen} -m {params.minlen} {input} > {output}"


rule get_hashing_seqs:
    input:
        config['hash_sequences'],
    output:
        OUTPUT + "hash_reference/hash.fasta",
    shell:
        """cp {input} {output}"""


rule get_whitelist:
    input:
        config['barcode_whitelist'],
    output:
        OUTPUT + "hash_reference/barcode_whitelist.txt",
    shell:
        """cp {input} {output}"""


rule get_translation:
    input:
        config['barcode_translation'],
    output:
        OUTPUT + "hash_reference/barcode_translation.txt",
    shell:
        """cp {input} {output}"""



rule phase_reads:
    input:
        fasta=OUTPUT + "hash_reference/hash.fasta",
        fastq=expand(OUTPUT + "hash_fastq/{sid}.fastq.gz", sid=hash_samples),
    output:
        log=OUTPUT + "reports/nanoplexer/hashing_report.txt",
    conda:
        "nanoplexer"
    params:
        indir=OUTPUT + "hash_fastq/",
        outdir=OUTPUT + "hashed_reads/",
    threads:
        36
    wildcard_constraints:
        sample_id='|'.join([re.escape(x) for x in set(hash_samples)]),
    shell:
        """cat {params.indir}*fastq.gz | nanoplexer \
        -b {input.fasta} -t {threads} -p {params.outdir} -l {output.log} - """


rule get_detected_barcode_fasta:
    input:
        OUTPUT + 'scanpy/raw.anndata.h5ad',
    output:
        OUTPUT + "hash_reference/detected_barcodes.fasta"
    conda:
        'scanpy'
    shell:
        """python scripts/get_detected_barcodes.py {input} {output}"""


rule get_barcode_translation:
    input:
        barcodes=OUTPUT + "hash_reference/detected_barcodes.fasta",
        trans=OUTPUT + "hash_reference/barcode_translation.txt",
    output:
        mapping=OUTPUT + "hash_reference/barcode_mapping.csv",
        fasta=OUTPUT + "hash_reference/translated_barcodes.fasta",
    conda:
        'bioinf'
    shell:
        """python scripts/get_barcode_translation.py {input.barcodes} \
        {input.trans} {output.mapping} {output.fasta}"""


rule index_barcodes:
    input:
        OUTPUT + "hash_reference/translated_barcodes.fasta",
    output:
        OUTPUT + "hash_reference/translated_barcodes.fasta.amb",
        OUTPUT + "hash_reference/translated_barcodes.fasta.ann",
        OUTPUT + "hash_reference/translated_barcodes.fasta.bwt",
        OUTPUT + "hash_reference/translated_barcodes.fasta.pac",
        OUTPUT + "hash_reference/translated_barcodes.fasta.sa",
    conda:
        "aligner"
    shell:
        """bwa index {input}"""


# get a list of the hash sequences identified
tag_list = [os.path.basename(x).replace('.fastq', '') for x in glob.glob(OUTPUT + "hashed_reads/" + "*.fastq")]
tag_list = [x for x in tag_list if not x  == 'unclassified']
wildcard_string = "|".join(tag_list)


rule align_hash_to_barcodes:
   input:
       ref=OUTPUT + "hash_reference/translated_barcodes.fasta",
       fastq=OUTPUT + "hashed_reads/{phase}.fastq",
   output:
       OUTPUT + "hash_alignment/{phase}.bam"
   conda:
       "aligner"
   threads:
       24
   params:
       min_seed=15,
       bandwidth=100,
       gap_open=6,
       gap_extension=2,
       clipping=5,
       min_score=1,
   wildcard_constraints:
       phase=wildcard_string,
   shell:
       """bwa mem -k {params.min_seed} -w {params.bandwidth} \
       -O {params.gap_open} -E {params.gap_extension} \
       -L {params.clipping} -T {params.min_score} \
       -t {threads} {input.ref} {input.fastq} | samtools view -Sb -> {output} """


rule reads_per_barcode:
    input:
        OUTPUT + "hash_alignment/{phase}.bam"
    output:
        OUTPUT + "reports/hash_count/{phase}.csv"
    wildcard_constraints:
        phase=wildcard_string,
    conda:
        "bioinf"
    shell:
        """python scripts/reads_per_barcode.py {input} {output}"""


rule build_hashmap:
    input:
        expand(OUTPUT + "reports/hash_count/{sid}.csv", sid=tag_list),
    output:
        hashmap=OUTPUT + "reports/hash_map/hashmap.csv",
        report=OUTPUT + "reports/hash_map/hashmap_summary.txt",
    conda:
        "bioinf"
    shell:
        """python scripts/build_hashmap.py {output.hashmap} {input} > {output.report}"""
      