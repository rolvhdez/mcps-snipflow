#!/usr/bin/env nextflow

include { buildInputs } from './modules/build_inputs'
include { segmentGenotype } from './modules/segment_genotype'
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

    // Make a list of the chromosomes to use
    Channel
        .of(expandRanges(params.chr_range.toString()))
        .ifEmpty { error "No chromosomes found in the range ${params.chr_range}" }
        .flatten()
        .set { chr_channel }

    // 01: Creates the input files for snipar using the MCPS
    // data that is available.
    buildInputs(
        params.baseline,
        params.kinship,
        params.pcs,
        params.outDir
    )
    
    // 02. For snipar to work, genotypes have to be separated by
    // individual chromosomes
    segmentGenotype(
        params.bed,
        params.bim,
        params.fam,
        chr_channel
    )
    
    // Then run FGWAS after both complete
    runFgwas(
        params.phenoIndex,
        params.estimator,
        params.kinship,
        params.outDir
    )
}