#!/usr/bin/env nextflow

/*
 * A custom pipeline that counts the number of entries in a FASTA file
 */


params.fasta= '/home/kai/nextflow/fasta_counter_pipeline/data/test_*.fasta' 

process fasta_counter {
    publishDir '/home/kai/nextflow/fasta_counter_pipeline/data/fasta_counts'
    
    input:
    val x

    output:
    path("${x.baseName}_counts.txt")

    script:
    """
    #will ouput the counts of each file to it's own respesctive file. 

    count=\$(cat $x | grep -o ">" | wc -l)
    echo "$x.baseName: \$count" >> ${x.baseName}_counts.txt
    """
}

workflow {
    def fasta_channel = Channel.fromPath(params.fasta)
    counted_fastas = fasta_counter(fasta_channel)
    counted_fastas.view{it}
}

