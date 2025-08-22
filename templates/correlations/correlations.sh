#/bin/bash

# For test, ld scores were computed with PLINK using:
#for i in {1..22}; do
#    plink --bfile MCPS_Freeze_150.GT_hg38.pVCF.revised_qc.autosomes-and-chrX_maf01 --r2 gz --chr $i --out "chr_$i"
#done
# LD Scores should be computed with the ibd.py script

# Compute correlations
correlate.py "${SUMSTATS}/chr_@" \
    --ldscores "${LDSCORES}/chr_@" \
    --chr_range 22 \
    --threads 28 \
    "${RESULTS}/chr_@"