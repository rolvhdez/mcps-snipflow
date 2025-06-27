#!/bin/bash
gwas.py \
    "${phenotype}" \
    --phen_index ${phenoIndex} \
    --bed "chr_@" \
    --pedigree "${pedigree}" \
    --covar "${covariates}" \
    --chr_range "${chr}" \
    --grm "${kinship}" \
    --sparse_thresh 0.05 \
    --cpu 32 --threads 2 --batch_size 150000 \
    --out "chr_@.regular"