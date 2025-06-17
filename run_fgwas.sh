#!/bin/bash

mkdir -p "${out_dir%/}/sumstats/"
pheno_id=$1
estimator=$2

# cycle for every 3 autosomes in decreasing order
chr_i=22

while [[ chr_i -gt 0 ]]; do

	chr_j=$((chr_i-2))

	# Compute total number of variants to be processed
	total_variants=0
	for x in $(seq $chr_i -1 $chr_j); do
		variants=$(awk -v chr="$x" '$1 == chr' "${bed}.bim" | wc -l)
		total_variants=$((total_variants+variants))
	done

	# Change computing requirements to avoid memory issues
	if [[ $total_variants -le 35000 ]]; then
		cpu=8
		threads=2
		batch_size=100000
	elif [[ $total_variants -le 70000 ]]; then
		cpu=6
		threads=2
		batch_size=50000
	else
		cpu=4
		threads=2
		batch_size=25000
	fi

	# Execute the FGWAS script
	if [[ $chr_j -gt 0 ]]; then
		parallel \
			--joblog "${out_dir%/}/sumstats/"$estimator"_joblog_$j-$i.log" \
			-j 3 ./fgwas/"$estimator".sh {1} {2} {3} {4} {5} \
			::: $pheno_id \
			::: $(seq $chr_i -1 $chr_j) \
			::: $cpu \
			::: $threads \
			::: $batch_size
		chr_i=$((chr_j-1))
	else
		./fgwas/"estimator".sh $pheno_id $chr_i $cpu $threads $batch_size
		exit 0
	fi
done