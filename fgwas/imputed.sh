#!/bin/bash

set -e

mkdir -p "${out_dir%/}/sumstats/"

{
    gwas.py \
        "${out_dir%/}/phenotype.txt" --phen_index $1 \
        --bed "${out_dir%/}/chr_segments/chr_@" \
        --imp "${out_dir%/}/chr_imputed/chr_@.imputed" \
        --pedigree "${out_dir%/}/pedigree.txt" \
        --covar "${out_dir%/}/covariates.txt" \
        --chr_range "$2" \
        --grm "${kinship}" \
        --sparse_thresh 0.05 \
        --cpu $3 --threads $4 --batch_size $5 \
        --out "${out_dir%/}/sumstats/chr_@.regular_imputed"
} 2>&1 | tee "${out_dir%/}/sumstats/regular_imputed_fgwas_$2.log"