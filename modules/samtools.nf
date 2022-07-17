params.outdir = 'results'

process SAMTOOLS {
    tag "SAMTOOLS on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(sam)

    output:
    tuple val(pair_id), path("*.bam"), emit: bam

    script:
    """
     samtools view -S -b ${sam} | \
     samtools sort -@ $task.cpus -o ${pair_id}.bam  
     samtools index ${pair_id}.bam 
    """
}