#!/usr/bin/env nextflow

// Input preparation
include { makeAgeSexKinship } from './modules/build_inputs'
include { makePedigree } from './modules/build_inputs'
include { makePhenoCovars } from './modules/build_inputs'
include { segmentGenotype } from './modules/segment_genotype'

// snipar
include { runFgwas } from './modules/run_fgwas'

def expandRanges(String str) {
    // Split the CHR_RANGE string into individual elements
    def elements = str.split()
    def chrom = []
        elements.each { element ->
            if (element.contains('-')) {
                def (start, end) = element.split('-').collect { it as int }
                chrom.addAll(start..end)
            } else {
                chrom.add(element as int)
            }
        }
    return chrom
}

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
    
    // Make a list of the chromosomes to use
    Channel
        .of(expandRanges(params.chr_range.toString()))
        .ifEmpty { error "No chromosomes found in the range ${params.chr_range}" }
        .flatten()
        .set { chr_channel }

    // 03. Run FGWAS after both complete
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