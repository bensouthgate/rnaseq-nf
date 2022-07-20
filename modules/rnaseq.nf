params.outdir = 'results'

include { HISAT2 } from './index.nf'
include { INDEX } from './index.nf'
include { QUANT } from './quant.nf'
include { FASTQC } from './fastqc.nf'

workflow RNASEQ {
  take:
    transcriptome
    read_pairs_ch
 
  main: 
  /*
   * INDEX(transcriptome)
   * FASTQC(read_pairs_ch)
   * QUANT(INDEX.out, read_pairs_ch)
   */

    HISAT2(genomeidx, read_pairs_ch)
    
  emit: 
     QUANT.out | concat(FASTQC.out) | collect
}