include { FASTQC } from './fastqc.nf'

workflow QC {
  take:
    read_pairs_ch
 
  main: 

    FASTQC(read_pairs_ch)
    
  emit: 
    fastqc_out_path = FASTQC.out.fastqc_out_path      // channel: [ path(qc_logs) ]
}