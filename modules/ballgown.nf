params.outdir = 'results'

process BALLGOWN {
    tag "BALLGOWN on $pheno_data"
    publishDir params.outdir, mode:'copy'

    input:
    path phenodata
    path ballgown_folders

    output:
    path "ballgown_transcripts_results.csv" 
    path "ballgown_genes_results.csv" 

    script:
    """
    RScript rnaseq_ballgown.R $phenodata $ballgown_folders
    """
}