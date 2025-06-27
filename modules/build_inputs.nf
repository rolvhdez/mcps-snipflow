process makeAgeSexKinship {
    containerOptions '--user root'
    input:
        path baseline
        path kinship
    output:
        path "agesex.csv", emit: "agesex"
        path "kinship.csv", emit: "kinship"
    script: template 'agesex-kinship.py'
}

process makePedigree {
    publishDir "${params.outDir}", mode: 'copy'
    containerOptions '--user root'
    input:
        path agesex
        path kinship
    output:
        path "pedigree.txt", emit: "pedigree"
    script: template 'pedigree.py'
}

process makePhenoCovars {
    publishDir "${params.outDir}", mode: 'copy'
    containerOptions '--user root'

    input:
        path baseline
        path kinship
        path pedigree
        path pcs
    output:
        path "phenotype.txt", emit: "phenotype"
        path "covariates.txt", emit: "covariates"
    script: template 'pheno-covars.py'
}