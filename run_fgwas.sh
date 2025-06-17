#!/bin/bash

mkdir -p "${out_dir%/}/sumstats/"
pheno_id=$1
estimator=$2

# Cycle for every 3 autosomes in decreasing order
chr_i=22
min_chr=1
while [[ chr_i -ge $min_chr ]]; do
	# Read the number of variants for a range of chromosomes
	chr_j=$((chr_i-2))
	n_vars=0
	for x in $(seq $chr_i -1 $chr_j); do
		vars=$(awk -v chr="$x" '$1 == chr' "${bed}.bim" | wc -l)
		n_vars=$((n_vars+vars))
	done

	# Optimized for 64 cores / 256GB RAM
	if [[ n_vars -le 35000 ]]; then
		# Small chromosomes (14-22)
		cpu=8
		threads=2
		batch_size=100000
	elif [[ n_vars -le 60000 ]]; then
		# Medium chromosomes (10-13)
		cpu=4
		threads=2
		batch_size=50000
	else 
		# Large chromosomes (1-7)
		cpu=6
		threads=1
		batch_size=12500
	fi

	# Execute the FGWAS script
	if [[ $chr_j -ge $min_chr ]]; then
		#echo "${chr_i} ${chr_j} ${n_vars} ${cpu} ${threads} ${batch_size}"
		parallel \
			--joblog "${out_dir%/}/sumstats/"$estimator"_joblog_$j-$i.log" \
			-j 3 ./fgwas/"$estimator".sh {1} {2} {3} {4} {5} \
			::: $pheno_id \
			::: $(seq $chr_i -1 $chr_j) \
			::: $cpu \
			::: $threads \
			::: $batch_size
	else
		cpu=24
		threads=2
		batch_size=100000
		#echo "${chr_i}  ${n_vars} ${cpu} ${threads} ${batch_size}"
		./fgwas/"estimator".sh $pheno_id $chr_i $cpu $threads $batch_size
	fi
	chr_i=$((chr_j-1))
done