params.outdir = 'results'

process STRINGTIE {
    tag "STRINGTIE on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    path gtffile
    tuple val(pair_id), path(bam)

    output:
    tuple val(pair_id), path("*.gtf"), emit: gtf
    path "mergelist.txt"
    path "stringtie_merged.gtf"

    script:

    """
    stringtie -p $task.cpus -G $gtffile -o ${pair_id}.gtf \
     -l ${pair_id} ${pair_id}.bam

    ls -1 *.gtf > mergelist.txt

    stringtie --merge -p $task.cpus -G  $gtffile \
    -o stringtie_merged.gtf mergelist.txt

    """
}
