#!/bin/bash
for i in {1..22}; do
    plink --bed "$BED" --bim "$BIM" --fam "$FAM" \
        --chr $i --make-bed \
        --out "${RESULTS}/genotypes/chr_$i"
done