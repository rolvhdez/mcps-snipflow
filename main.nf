#!/usr/bin/env nextflow

// Input preparation
include { makeAgeSexKinship } from './modules/build_inputs'
include { makePedigree } from './modules/build_inputs'
include { makePhenoCovars } from './modules/build_inputs'
include { segmentGenotype } from './modules/segment_genotype'

// SNIPAR
include { runFgwas } from './modules/run_fgwas'

workflow {
    // 01: Creates the input files for snipar using the MCPS data that is available.
    makeAgeSexKinship(
        params.baseline,
        params.kinship
    )
    makePedigree(
        makeAgeSexKinship.output.agesex,
        makeAgeSexKinship.output.kinship
    )
    makePhenoCovars(
        params.baseline,
        params.kinship,
        makePedigree.output.pedigree,
        params.pcs
    )
    
    // 02. For snipar to work, genotypes have to be separated by individual chromosomes
    segmentGenotype(
        params.bed,
        params.bim,
        params.fam
    )

    // 03. Run FGWAS according to selected estimator
    runFgwas(
        params.estimator,
        makePhenoCovars.output.phenotype,
        params.phenoIndex,
        segmentGenotype.output,
        makePedigree.output.pedigree,
        makePhenoCovars.output.covariates,
        params.chr_range,
        params.kinship
    )
}