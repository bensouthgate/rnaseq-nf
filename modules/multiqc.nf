params.outdir = 'results'

process MULTIQC {
    publishDir params.outdir, mode:'copy'

    /* 
    * This puts each of the inputs into their own folder
    * Not necessary but prevents same file name conflicts
    * See multiQC Website for details on how to specify multiqc process
    * https://multiqc.info/docs/#using-multiqc-in-pipelines
    */

    input:
    /* 
    * path ('fastqc/*')
    * path ('trimgalore/fastqc/*')
    * path ('trimgalore/*')
    * path ('sortmerna/*')
    * path ('star/*')
    */
    path ('fastqc/*/*')
    path ('hisat2/*')
    path ('samtools/stats/*')
    path ('samtools/flagstat/*')
    path ('samtools/idxstats/*') 
    /*
    * path ('rsem/*')
    * path ('salmon/*')
    */
    path(config) 

    output:
    path('multiqc_report.html')

    script:
    """
    cp $config/* .
    echo "custom_logo: \$PWD/logo.png" >> multiqc_config.yaml
    multiqc -f .
    """
}