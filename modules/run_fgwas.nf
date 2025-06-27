process runFgwas {
    publishDir "${params.outDir}/sumstats/", mode: 'copy'
    containerOptions '--user root'
    input:
        // Selection of script
        val estimator

        // Minimal input requirements
        path phenotype
        val phenoIndex
        tuple path(bed), path(bim), path(fam)
        path pedigree
        path covariates
        val chr_range
        path kinship


    output:
        path "chr_*.*.sumstats.gz", emit: "sumstats"
        path "chr_*.*.hdf5", emit: "hdf5"

    script: 
        if ( estimator == 'regular' )
            // Parent-offspring trios and Sibling Differences (no imputation)
            template 'fgwas/regular.sh'
        else
            error "No estimator '${estimator}' available."
}