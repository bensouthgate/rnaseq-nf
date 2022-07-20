params.outdir = 'results'

process HISAT2_BUILD {
    tag "HISAT2_BUILD on $fasta"
    publishDir params.outdir, mode:'copy'

    input:
    path fasta

    output:
    path "hisat2", emit: genomeidx

    script:

    """
    mkdir hisat2

    hisat2-build -p $task.cpus $fasta hisat2/${fasta.baseName}
    """
}

process HISAT2_ASSEMBLE {
    tag "HISAT2_ASSEMBLE on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    path genomeidx
    tuple val(pair_id), path(reads)

    output:
    tuple val(pair_id), path("*.sam"), emit: sam
    tuple val(pair_id), path("*.alnstats"), emit: alnstats

    script:

    """
    hisat2 -p $task.cpus --dta -x $genomeidx \
     -1 ${reads[1]} \
     -2 ${reads[2]} \
     -S ${pair_id}.sam 2> ${pair_id}.alnstats
    """
}
