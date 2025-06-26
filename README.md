# SNIPflow: A familiar pipeline

This Nextflow pipeline implements the family-based GWAS (FGWAS) workflow described in the *snipar* protocol by Young, *et al*. ([2022](https://www.nature.com/articles/s41588-022-01085-0)) and Guan, *et al.* ([2025](https://www.nature.com/articles/s41588-025-02118-0)) for the Mexico Prospective Study (MCPS) project ([rolvhdez/mcps-snipflow:v0.1.1](https://github.com/rolvhdez/mcps-snipflow/tree/v0.1.0)).

> The workflow currently performs an FGWAS analysis without parental imputations.

## Key Differences from Original Implementation
- Nextflow-based: Provides built-in parallelization and cloud compatibility
- Containerized: All dependencies pre-packaged in Docker containers
- Simplified execution: Single command to run entire workflow
- Reproducible: Version-controlled pipeline with explicit parameters

## Quick start

1. Clone this repository:

    ```shell
    git clone https://github.com/rolvhdez/mcps-snipflow.git && cd mcps-snipflow/ && git checkout nextflow
    ```

2. (Optional) Prepare a `params.yml` file with paths to your input files:

    ```json
    {
       "bed": "path/to/your/file.bed",
       "bim": "path/to/your/file.bim",
       "fam": "path/to/your/file.fam",
       "baseline": "path/to/your/baseline.csv",
       "kinship": "path/to/your/kinship.seg",
       "pcs": "path/to/your/principal-components.txt",
       "phenoIndex": 1,
       "chr_range": "1-22",
       "estimator": "regular",
       "outDir": "./results",
    }
    ```

3. Run the workflow:
    ```shell
    nextflow run main.nf -params-file params.json -resume
    ```