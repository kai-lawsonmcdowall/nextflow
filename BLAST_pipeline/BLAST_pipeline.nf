#!/usr/bin/env nextflow
 
"""
Not sure I can run this as it has custom functions (at least not locally)
"""

/*
 * Defines the pipeline input parameters (with a default value for each one).
 * Each of the following parameters can be specified as command line options.
 */

//updated basedir to project dir to make it not legacy

params.query = "$baseDir/data/test_*.fasta"
params.db = "$baseDir/data/blast-db/pdb/tiny"
params.out = "result.txt"
params.chunkSize = 100
 
//updated file to path to make it not legacy. 
db_name = path(params.db).name // returns of the name of the file passed in via params.db (according to chatgpt)
db_dir = path(params.db).parent // returns the parent directory of the file.
 
 
workflow {
    /*
     * Create a channel emitting the given query fasta file(s).
     * Split the file into chunks containing as many sequences as defined by the parameter 'chunkSize'.
     * Finally, assign the resulting channel to the variable 'ch_fasta'
     */
    Channel
        .fromPath(params.query)
        .splitFasta(by: params.chunkSize, file:true) //This is a custom method provided to the channel. 
        .set { ch_fasta }
 
    /*
     * Execute a BLAST job for each chunk emitted by the 'ch_fasta' channel
     * and emit the resulting BLAST matches.
     */
    ch_hits = blast(ch_fasta, db_dir)
 
    /*
     * Each time a file emitted by the 'blast' process, an extract job is executed,
     * producing a file containing the matching sequences.
     */
    ch_sequences = extract(ch_hits, db_dir)
 
    /*
     * Collect all the sequences files into a single file
     * and print the resulting file contents when complete.
     */
    ch_sequences
        .collectFile(name: params.out)
        .view { file -> "matching sequences:\n ${file.text}" }
}
 
 
process blast {
    input:
    path 'query.fa'
    path db
 
    output:
    path 'top_hits'
 
    """
    blastp -db $db/$db_name -query query.fa -outfmt 6 > blast_result
    cat blast_result | head -n 10 | cut -f 2 > top_hits
    """
}
 
 
process extract {
    input:
    path 'top_hits'
    path db
 
    output:
    path 'sequences'
 
    """
    blastdbcmd -db $db/$db_name -entry_batch top_hits | head -n 10 > sequences
    """
}