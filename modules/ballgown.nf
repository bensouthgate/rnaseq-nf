params.outdir = 'results'

process BALLGOWN {
    tag "BALLGOWN on $pheno_data"
    publishDir params.outdir, mode:'copy'

    input:
    path pheno_data

    output:
    path "chrX_transcripts_results.csv" 
    path "chrX_genes_results.csv" 

    script:
    """
    RScript rnaseq_ballgown.R "$pheno_data"
    """
}