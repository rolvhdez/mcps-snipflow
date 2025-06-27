#!/bin/bash

input_json="./base_params.json"
tmp_json="/tmp/params.json"
phenotype_ids=()
out_dir_base="/path/to/output/directory"

for phen_id in "${phenotype_ids[@]}"; do
    # Create the output directory for the current phenotype
    phen_dir="${out_dir_base}/phenotype-${phen_id}"
    mkdir -p "${phen_dir}"

    # Create a temporary JSON file with the updated phenotype index
    jq --arg phen_id "$phen_id" '.phenoIndex += ($phen_id | tonumber)' "$input_json" > "$tmp_json"
    jq --arg out_dir "${phen_dir}" '.outDir = $out_dir' "$tmp_json" > "$tmp_json.tmp" && mv "$tmp_json.tmp" "$tmp_json"

    # Write the used params file
    cat "$tmp_json" > "${phen_dir}/params.json"

    # Run the Nextflow pipeline with the updated parameters
    nextflow run main.nf -resume \
        -params-file "$tmp_json" \
        -with-report "${phen_dir}/report.html" \
        -with-timeline "${phen_dir}/timeline.html" \
        -with-trace "${phen_dir}/trace.txt"
done