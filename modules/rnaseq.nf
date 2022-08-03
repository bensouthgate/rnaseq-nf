params.outdir = 'results'

include { HISAT2_BUILD } from './hisat.nf'
include { HISAT2_ASSEMBLE } from './hisat.nf'

include { INDEX } from './index.nf'
include { QUANT } from './quant.nf'
include { FASTQC } from './fastqc.nf'

workflow RNASEQ {
  take:
    fasta
    read_pairs_ch
 
  main: 
  /*
   * INDEX(transcriptome)
   * FASTQC(read_pairs_ch)
   * QUANT(INDEX.out, read_pairs_ch)
   */

    HISAT2_BUILD(fasta)
    HISAT2_ASSEMBLE(fasta, HISAT2_BUILD.out.genomeidx, read_pairs_ch)
    
  emit: 
    genomeidx = HISAT2_BUILD.out.genomeidx      // channel: [ path(genomeidx) ]
    sam = HISAT2_ASSEMBLE.out.sam               // channel: [ val(pair_id), [ sam ] ]
    alnstats = HISAT2_ASSEMBLE.out.alnstats     // channel: [ val(pair_id), [ alnstats ] ]
}