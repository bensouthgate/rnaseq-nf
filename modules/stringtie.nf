params.outdir = 'results'

process STRINGTIE {
    tag "STRINGTIE on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    path gtf_file
    tuple val(pair_id), path(bam)

    output:
    tuple val(pair_id), path("*.gtf"), emit: gtf

    script:

    """
    stringtie -p $task.cpus -G $gtf_file -o ${pair_id}.gtf -l ${pair_id} $bam
    """
}

process STRINGTIE_MERGE {
    tag "STRINGTIE_MERGE on $gtfs"
    publishDir params.outdir, mode:'copy'

    input:
    path gtf_file
    path gtfs // need to make the gtf files available as well.

    output:
    path "stringtie_merged.gtf", emit: merged_gtf

    script:

    """
    stringtie --merge -p $task.cpus -G $gtf_file -o stringtie_merged.gtf $gtfs
    """
}