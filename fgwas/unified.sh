#!/bin/bash

set -e

mkdir -p "${out_dir%/}/sumstats/"

{
    # instance_type = "mem1_ssd1_v2_x16"
    gwas.py \
        "${out_dir%/}/phenotype.txt" --phen_index $1 \
        --impute_unrel \
        --bed "${out_dir%/}/chr_segments/chr_@" \
        --imp "${out_dir%/}/chr_imputed/chr_@.imputed" \
        --pedigree "${out_dir%/}/pedigree.txt" \
        --covar "${out_dir%/}/covariates.txt" \
        --chr_range "$2" \
        --grm "${kinship}" \
        --sparse_thresh 0.05 \
        --cpu 8 --threads 2 --batch_size 100000 \
        --out "${out_dir%/}/sumstats/chr_@.unified"
} 2>&1 | tee "${out_dir%/}/sumstats/unified_fgwas_$2.log"