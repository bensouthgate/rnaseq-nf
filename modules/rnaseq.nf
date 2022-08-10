params.outdir = 'results'

include { HISAT2_BUILD } from './hisat.nf'
include { HISAT2_ASSEMBLE } from './hisat.nf'

include { SAMTOOLS_VIEW } from './samtools.nf'
include { SAMTOOLS_SORT } from './samtools.nf'
include { SAMTOOLS_INDEX } from './samtools.nf'

include { SAMTOOLS_STATS } from './samtools.nf'
include { SAMTOOLS_FLAGSTAT } from './samtools.nf'
include { SAMTOOLS_IDXSTATS } from './samtools.nf'

include { STRINGTIE } from './stringtie.nf'
include { STRINGTIE_MERGE } from './stringtie.nf'
include { STRINGTIE_ABUN } from './stringtie.nf'

include { BALLGOWN } from './ballgown.nf'

workflow RNASEQ {

  take:

    fasta
    read_pairs_ch
    gtf_file
    phenodata

  main: 

    HISAT2_BUILD ( fasta )

    HISAT2_ASSEMBLE ( fasta, HISAT2_BUILD.out.genomeidx, read_pairs_ch )

    SAMTOOLS_VIEW ( HISAT2_ASSEMBLE.out.sam )
    SAMTOOLS_SORT ( SAMTOOLS_VIEW.out.bam )
    SAMTOOLS_INDEX ( SAMTOOLS_SORT.out.sorted_bam )

    // add bai to channel by pair_id at index 0
    // channel: [ val(pair_id), [ bam ] , [ bai ] ]
    ch_bam_bai =  SAMTOOLS_SORT.out.sorted_bam.join(SAMTOOLS_INDEX.out.bai, by: [0], remainder: true)

    SAMTOOLS_STATS ( SAMTOOLS_SORT.out.sorted_bam, fasta )
    SAMTOOLS_FLAGSTAT ( SAMTOOLS_SORT.out.sorted_bam )
    SAMTOOLS_IDXSTATS ( ch_bam_bai )

    STRINGTIE ( gtf_file, SAMTOOLS_SORT.out.sorted_bam )
    STRINGTIE_MERGE ( gtf_file, STRINGTIE.out.gtf.collect{it[1]} )
    STRINGTIE_ABUN ( STRINGTIE_MERGE.out.merged_gtf, SAMTOOLS_SORT.out.sorted_bam )

    BALLGOWN ( phenodata, STRINGTIE_ABUN.out.ballgown.collect{it[1]} )

  emit: 

    genomeidx = HISAT2_BUILD.out.genomeidx      // channel: [ path(genomeidx) ]

    sam = HISAT2_ASSEMBLE.out.sam               // channel: [ val(pair_id), [ sam ] ]
    alnstats = HISAT2_ASSEMBLE.out.alnstats     // channel: [ val(pair_id), [ alnstats ] ]

    bam = SAMTOOLS_VIEW.out.bam                 // channel: [ val(pair_id), [ bam ] ]
    sorted_bam = SAMTOOLS_SORT.out.sorted_bam   // channel: [ val(pair_id), [ bam ] ]
    bai = SAMTOOLS_INDEX.out.bai                // channel: [ val(pair_id), [ bai] ]

    stats = SAMTOOLS_STATS.out.stats            // channel: [ val(pair_id), [ stats ] ]
    flagstat = SAMTOOLS_FLAGSTAT.out.flagstat   // channel: [ val(pair_id), [ flagstat ] ]
    idxstats = SAMTOOLS_IDXSTATS.out.idxstats   // channel: [ val(pair_id), [ idxstats ] ]

    gtf = STRINGTIE.out.gtf                     // channel: [ val(pair_id), [ gtf ] ]
    merged_gtf = STRINGTIE_MERGE.out.merged_gtf // channel: [ path(merged_gtf) ]

    ballgown = STRINGTIE_ABUN.out.ballgown      // channel: [ val(pair_id), [ ballgown ] ]
}