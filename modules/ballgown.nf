params.outdir = 'results'

process BALLGOWN {
    tag "BALLGOWN on $ballgown_folders"
    publishDir params.outdir, mode:'copy'
    debug true

    input:
    path phenodata
    path ballgown_folders

    output:
    path "ballgown_transcripts_results.csv", emit: transcripts_results
    path "ballgown_genes_results.csv", emit: genes_results

    script:
    
    """
    head $phenodata | echo
    Rscript ${baseDir}/bin/rnaseq_ballgown.R $phenodata $ballgown_folders
    """
}