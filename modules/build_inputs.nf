process buildInputs {
    container 'your-docker-image'
    publishDir "${params.outDir}", mode: 'copy'
    
    input:
    path baseline
    path kinship
    path pcs
    val outDir
    
    output:
    path("${outDir}/pedigree.txt"), emit: pedigree
    path("${outDir}/phenotype.txt"), emit: phenotype
    path("${outDir}/covariates.txt"), emit: covariates
    
    script:
    """
    python3 resources/build_inputs.py \
        --baseline $baseline \
        --kinship $kinship \
        --pcs $pcs \
        --outDir $outDir
    """
}