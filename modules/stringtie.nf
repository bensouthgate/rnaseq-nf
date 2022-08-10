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
    stringtie $bam -p $task.cpus -G $gtf_file -o ${pair_id}.gtf -l ${pair_id}
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

process STRINGTIE_ABUN {
    tag "STRINGTIE_ABUN on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    path "stringtie_merged.gtf"
    tuple val(pair_id), path(bam)

    output:
    tuple val(pair_id), path("*.transcripts.gtf"), emit: transcripts_gtf
    tuple val(pair_id), path("*.gene.abundance.txt"), emit: gene_abundance
    tuple val(pair_id), path("*.coverage.gtf"), emit: coverage_gtf
    tuple val(pair_id), path(pair_id), emit: ballgown

    script:
    //  stringtie $bam -e -p $task.cpus -G stringtie_merged.gtf -o ${pair_id}.transcripts.gtf -A ${pair_id}.gene.abundance.txt -C ${pair_id}.coverage.gtf -b ${pair_id}.ballgown
    // tuple val(pair_id), path("*.ballgown"), emit: ballgown

    """
    stringtie $bam -e -p $task.cpus -G stringtie_merged.gtf -o ${pair_id}.transcripts.gtf -A ${pair_id}.gene.abundance.txt -C ${pair_id}.coverage.gtf -b ${pair_id}
    """
}