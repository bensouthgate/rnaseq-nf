params.outdir = 'results'

process SAMTOOLS_VIEW {
    tag "SAMTOOLS_VIEW on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(sam)

    output:
    tuple val(pair_id), path("*.bam"), emit: bam

    script:
    
    """
    samtools view -S -b $sam > ${pair_id}.bam
    """
}

process SAMTOOLS_SORT {
    tag "SAMTOOLS_SORT on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(bam)

    output:
    tuple val(pair_id), path("*.sorted.bam"), emit: sorted_bam

    script:
    
    """
    samtools sort -@ $task.cpus -o ${pair_id}.sorted.bam $bam 
    """
}

process SAMTOOLS_INDEX {
    tag "SAMTOOLS_INDEX on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(bam) // generally sorted_bam

    output:
    tuple val(pair_id), path("*.bai"), emit: bai

    script:
    
    """
    samtools index ${bam}
    """
}

process SAMTOOLS_STATS {
    tag "SAMTOOLS_STATS on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(bam)
    path fasta

    output:
    tuple val(pair_id), path("*.stats"), emit: stats

    script:
    def reference = fasta ? "--reference ${fasta}" : ""
    
    """
    samtools \\
        stats \\
        --threads ${task.cpus-1} \\
        ${reference} \\
        ${bam} \\
        > ${bam}.stats
    """
}

process SAMTOOLS_FLAGSTAT {
    tag "SAMTOOLS_FLAGSTAT on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(bam)

    output:
    tuple val(pair_id), path("*.flagstat"), emit: flagstat

    script:

    """
    samtools \\
        flagstat \\
        --threads ${task.cpus-1} \\
        $bam \\
        > ${bam}.flagstat
    """
}


process SAMTOOLS_IDXSTATS {
    tag "SAMTOOLS_IDXSTATS on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    // oddly this gives samtools access to bai files even though they are not explicitly called.
    tuple val(pair_id), path(bam), path(bai) 

    output:
    tuple val(pair_id), path("*.idxstats"), emit: idxstats

    script:

    """
    samtools \\
        idxstats \\
        $bam \\
        > ${bam}.idxstats
    """
}


process SAMTOOLS {
    tag "SAMTOOLS on $pair_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(pair_id), path(sam)

    output:
    tuple val(pair_id), path("*.bam"), emit: bam
    tuple val(pair_id), path("*.bai"), emit: bai

    script:
    
    """
    samtools view -S -b $sam | \
    samtools sort -@ $task.cpus -o ${pair_id}.bam  
    samtools index ${pair_id}.bam 
    """
}