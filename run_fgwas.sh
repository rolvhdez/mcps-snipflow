#!/bin/bash

mkdir -p "${out_dir%/}/sumstats/"
pheno_id=$1
estimator=$2

# Start and end chromosomes
chr_i=7
min_chr=1

# Computational power
cpu=8
threads=2

# Cycle for each autosome in decreasing order
while [[ chr_i -ge $min_chr ]]; do

	if [[ chr_i -ge 8 ]]; then
		# every 3 autosomes
		chr_j=$((chr_i-2))
		batch_size=100000
		n_jobs=3
	else
		# every 2 autosomes
		chr_j=$((chr_i-1))
		batch_size=50000
		n_jobs=2
	fi

	# Execute the FGWAS script
	if [[ $chr_j -ge $min_chr ]]; then
		#echo "${chr_i} ${chr_j} ${n_vars} ${cpu} ${threads} ${batch_size}"
		parallel \
			--joblog "${out_dir%/}/sumstats/"$estimator"_joblog_$chr_j-$chr_i.log" \
			-j $n_jobs ./fgwas/"$estimator".sh {1} {2} {3} {4} {5} \
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