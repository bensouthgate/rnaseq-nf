params.outdir = 'results'

process STRINGTIE {
    tag "STRINGTIE on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    path "stringtie_merged.gtf"
    tuple val(pair_id), path(reads)

    output:
    tuple val(pair_id), path("*.gtf"), emit: dsamplegtf

    script:

    """
    ## not sure but
    ## asking for base name here so for example 
    ## for ggal_liver_1
    ## the bam should be: ggal_liver
    ## and the gtf should be: ggal
    dsample="${pair_id%%_*}"
    stringtie -e -B -p $task.cpus -G stringtie_merged.gtf \
    -o \${dsample}.gtf ${pair_id}.bam
    """
}