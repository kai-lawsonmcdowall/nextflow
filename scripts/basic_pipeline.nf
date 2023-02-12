#!/usr/bin/env nextflow
 
/*
 * The most basic of nextflow pipelines
 * Initalize the pipeline parameter "in" with a directory. 
 * $BaseDir: The directory where the main workflow script is located
 * tried to spice it up a little bit by adding in my own module. 
 */

params.in = "/home/kai/nextflow/data/test.fasta"
params.outdir = "/home/kai/nextflow/data"

/*
 * Split a fasta file into multiple files
 */
process splitSequences {
 
    // path input stages fies from the params.in, we declare the process input file as input.fa
    input:
    path 'input.fa'
 
    //. files whose name match the pattern seq_* are delcared as the output of this process. 
    output:
    path 'seq_*'
 

    // actual script executed
    """
    awk '/^>/{f="seq_"++d} {print > f}' < input.fa
    """
}
 
/*
 * Reverse the sequences
 * The second process, which receives the splits produced by the previous process and reverses their content.
 */
process reverse {
 
    input:
    path y
 
    output:
    stdout
 
    """
    cat $y | rev
    """
}


process uncaptialize {
    publishDir params.outdir
    
    input:
    stdin

    output:
    stdout

    """
    #!/usr/bin/env python
    import sys
    for line in sys.stdin:
        new_line = line[:-1].lower()
        sys.stdout.write(f'{new_line}\\n')

    """

}



 
/*
 * Define the workflow
 */
workflow {
    splitSequences(params.in) \
      | reverse \
      | uncaptialize \
      | view
      
}

