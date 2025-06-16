#!/bin/bash

mkdir -p "${out_dir%/}/sumstats/"
pheno_id=$1
estimator=$2

# cycle for every 3 autosomes in decreasing order
i=22 # last autosome

# Define out_dir if not already set
out_dir=${out_dir:-.}

while [[ i -gt 0 ]]; do
	j=$(( i-2 ))
	if [ $j -lt 1 ]; then 
		# last chromosome is run separately
		./fgwas/"$estimator".sh $pheno_id $i
		exit 0
	else
		# run the FGWAS in parallel
		parallel \
			--joblog "${out_dir%/}/sumstats/"$estimator"_joblog_$j-$i.log" \
			-j 3 ./fgwas/"$estimator".sh {1} {2} ::: $pheno_id ::: $(seq $i -1 $j)
		i=$((j-1))
	fi
done