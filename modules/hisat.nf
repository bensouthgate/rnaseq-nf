params.outdir = 'results'

process HISAT {
    tag "HISAT on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    path genomeidx
    tuple val(pair_id), path(reads)

    output:
    tuple val(pair_id), path("*.sam"), emit: sam
    path "${pair_id}.alnstats", emit: alnstats

    script:

    """
    hisat2 -p $task.cpus --dta -x ${genomeidx} \
     -1 ${reads[1]} \
     -2 ${reads[2]} \
     -S ${pair_id}.sam 2> ${pair_id}.alnstats
    """
}
