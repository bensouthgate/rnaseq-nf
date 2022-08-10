#!/usr/bin/env nextflow 

/* 
 * Copyright (c) 2020-2021, Seqera Labs 
 * Copyright (c) 2013-2019, Centre for Genomic Regulation (CRG).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. 
 * 
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 */

/* 
 * enables modules 
 */
nextflow.enable.dsl = 2

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */

log.info """\
 R N A S E Q - N F   P I P E L I N E
 ===================================
 fasta        : ${params.fasta}
 transcriptome: ${params.transcriptome}
 reads        : ${params.reads}
 outdir       : ${params.outdir}
 """

// import modules
include { QC } from './modules/qc.nf'
include { RNASEQ } from './modules/rnaseq.nf'
include { MULTIQC } from './modules/multiqc.nf'

/* 
 * main script flow
 */
workflow {
  read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
  QC( read_pairs_ch )
  RNASEQ( params.fasta, read_pairs_ch, params.gtf_file, params.phenodata )

  /* 
  * Here we collect (so collapse into single entity), and then take the file names from the tuple
  * We do this using the groovy closure {it[1]} and ifEmpty returns empty list if not present
  */

  MULTIQC ( 
    QC.out.fastqc_out_path.ifEmpty([]),             // channel: [ path(qc_logs) ]

    RNASEQ.out.alnstats.collect{it[1]}.ifEmpty([]), // channel: [ val(pair_id), [ alnstats ] ]

    RNASEQ.out.stats.collect{it[1]}.ifEmpty([]),    // channel: [ val(pair_id), [ stats ] ]
    RNASEQ.out.flagstat.collect{it[1]}.ifEmpty([]), // channel: [ val(pair_id), [ flagstat ] ]
    RNASEQ.out.idxstats.collect{it[1]}.ifEmpty([]), // channel: [ val(pair_id), [ idxstats ] ]

    params.multiqc
  )
}

/* 
 * completion handler
 */
workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}
