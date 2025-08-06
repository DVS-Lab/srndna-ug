#!/bin/bash

# ensure paths are correct
maindir=~/work/srndna-ug #this should be the only line that has to change if the rest of the script is set up correctly
scriptdir=$maindir/code


mapfile -t myArray < sublist_all.txt


# grab the first 10 elements
ntasks=14
counter=0
for task in ultimatum; do
	for ppi in "0"; do #"VS_thr5" "dmn"; do # 0 "VS_thr5" "dmn"; do # putting 0 first will indicate "activation"
		#for run in 1 2; do
		
		while [ $counter -lt ${#myArray[@]} ]; do
			subjects=${myArray[@]:$counter:$ntasks}
			echo $subjects
			let counter=$counter+$ntasks
			qsub -v subjects="${subjects[@]}" L1stats-hpc.sh
		done

			bash $SCRIPTNAME $sub $run $ppi $task &
	  		sleep 1s
			done	  	
	  	done
