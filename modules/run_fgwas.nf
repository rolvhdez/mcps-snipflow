process runFgwas {
    publishDir "${params.outDir}/sumstats/", mode: 'copy'
    containerOptions '--user root'
    input:
        // Selection of script
        val estimator

        // Minimal input requirements
        path phenotype
        val phenoIndex
        path genotypes
        path pedigree
        path covariates
        val chr
        path kinship

    output:
        path "chr_*.*.gz", emit: "sumstats"
        path "chr_*.*.hdf5", emit: "hdf5"

    script: 
        if ( estimator == 'regular' )
            // Parent-offspring trios and Sibling Differences (no imputation)
            template 'fgwas/regular.sh'
        else
            error "No estimator '${estimator}' available."
}