process runFgwas {
    container 'your-docker-image'
    publishDir "${params.outDir}/sumstats/", mode: 'copy'
    
    input:
    val phenoIndex
    val estimator
    path kinship
    path outDir
    
    output:
    path("${outDir}/sumstats/*"), emit: sumstats
    
    script:
    """
    #!/bin/bash
    bin/run_fgwas.sh $phenoIndex $estimator
    """
}