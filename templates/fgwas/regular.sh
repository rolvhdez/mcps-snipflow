#!/bin/bash
bedfile=\$( basename ${bed} .bed )
gwas.py \
    "${phenotype}" \
    --phen_index ${phenoIndex} \
    --bed "\$bedfile" \
    --pedigree "${pedigree}" \
    --covar "${covariates}" \
    --chr_range "${chr_range}" \
    --grm "${kinship}" \
    --sparse_thresh 0.05 \
    --cpu 8 --threads 2 --batch_size 50000 \
    --out "chr_@.regular"