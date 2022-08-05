params.outdir = 'results'

process FASTQC {
    tag "FASTQC on $sample_id"
    publishDir params.outdir, mode:'copy'
    
    /* Can use the below to see print out messages
    * debug true
    */

    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_${sample_id}_logs", emit: fastqc_out_path 

    script:

    /* Note you cannot specify a new variable here which is then used for the output 
    * We can use variables here for the script - but not for other things. 
    */

    /* Using regex here to REMOVE all trailing newlines */
    def sample_id_new = ("${sample_id}" - ~/\r?\n|\r/)

    """
    mkdir fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -f fastq $reads
    """
}
