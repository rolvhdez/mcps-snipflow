#!/bin/bash

# INPUT PARAMETERS - MODIFY AS NEEDED #
phenotype_ids=(1 2 3) # Phenotype IDs to iterate over
out_dir_base="/path/to/your/output/dir" && mkdir -p "${out_dir_base}"
dx_out_dir="/path/to/your/dnanexus/dir"

# DO NOT CHANGE #
input_json="./base_params.json"
tmp_json="/tmp/params.json"
params_dir="${out_dir_base}/params" && mkdir -p "${params_dir}"

dx mkdir "$DX_PROJECT_CONTEXT_ID:${dx_outdir}/params" # for uploading params later

# ITERATE OVER PHENOTYPE IDS
for phen_id in "${phenotype_ids[@]}"; do
    phen_id_str=$(printf "%03d" "$phen_id") # makes a 3-digit phenotype ID string
    log_dir="${out_dir_base}/${phen_id_str}-log" && mkdir -p "${log_dir}" # log directory

    # Create a temporary JSON file with the updated phenotype index
    jq --arg phen_id "$phen_id" '.phenoIndex += ($phen_id | tonumber)' "$input_json" > "$tmp_json"
    jq --arg out_dir "${out_dir_base}" '.outDir = $out_dir' "$tmp_json" > "$tmp_json.tmp" && mv "$tmp_json.tmp" "$tmp_json"

    # Write the used params file
    cat "$tmp_json" > "${params_dir}/${phen_id_str}-params.json"

    # RUN NEXTFLOW PIPELINE #
    nextflow run main.nf -resume \
        -params-file "$tmp_json" \
        -with-report "${log_dir}/report.html" \
        -with-timeline "${log_dir}/timeline.html" \
        -with-trace "${log_dir}/trace.txt"

    # Upload to DNAnexus
    dx upload -r "${out_dir_base}/${phen_id}-sumstats/" --path "$DX_PROJECT_CONTEXT_ID:${dx_outdir}/"
    dx upload -r "${out_dir_base}/${log_dir}/" --path "$DX_PROJECT_CONTEXT_ID:${dx_outdir}/"
    dx upload "${params_dir}/${phen_id_str}-params.json" --path "$DX_PROJECT_CONTEXT_ID:${dx_outdir}/params/"
done

# Terminate the job
dx terminate "$DX_JOB_ID"