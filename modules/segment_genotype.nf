process segmentGenotype {
//    publishDir "${params.outDir}/chr_segments/", mode: 'copy'
    
    input:
    path bed
    path bim
    path fam
    val chr
    
    output:
    file "${bed.baseName}_chr$chr.{bed,bim,fam}"
    
    script:
    """
    #!/bin/bash
    plink --bed "$bed" --bim "$bim" --fam "$fam" --chr $chr --make-bed --out "${bed.baseName}_chr$chr"
    """
}