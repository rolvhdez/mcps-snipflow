process segmentGenotype {
    containerOptions '--user root'
    input:
        path bed
        path bim
        path fam
    output:
        path "chr_*.{bed,bim,fam}"
    script:
    """
    #!/bin/bash
    for i in {1..22}; do
        plink2 --bed "$bed" --bim "$bim" --fam "$fam" \
            --chr \$i --make-bed \
            --out "chr_\$i"
    done
    """
}