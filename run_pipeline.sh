#!/bin/bash

input_json="./base_params.json"
tmp_json="/tmp/params.json"
phenotype_ids=()
out_dir_base="/path/to/your/output/dir" && mkdir -p "${out_dir_base}"
params_dir="${out_dir_base}/params" && mkdir -p "${params_dir}"

for phen_id in "${phenotype_ids[@]}"; do
    phen_id_str=$(printf "%03d" "$phen_id")
    log_dir="${out_dir_base}/${phen_id_str}-log" && mkdir -p "${log_dir}"

    # Create a temporary JSON file with the updated phenotype index
    jq --arg phen_id "$phen_id" '.phenoIndex += ($phen_id | tonumber)' "$input_json" > "$tmp_json"
    jq --arg out_dir "${out_dir_base}" '.outDir = $out_dir' "$tmp_json" > "$tmp_json.tmp" && mv "$tmp_json.tmp" "$tmp_json"

    # Write the used params file
    cat "$tmp_json" > "${params_dir}/${phen_id_str}-params.json"

    # Run the Nextflow pipeline with the updated parameters
    nextflow run main.nf -resume \
        -params-file "$tmp_json" \
        -with-report "${log_dir}/report.html" \
        -with-timeline "${log_dir}/timeline.html" \
        -with-trace "${log_dir}/trace.txt"
done