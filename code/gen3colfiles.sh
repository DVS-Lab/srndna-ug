#!/usr/bin/env bash

# this script will convert your BIDS *events.tsv files into the 3-col format for FSL
# it relies on Tom Nichols' converter, which we store locally under /data/tools 
# https://github.com/bids-standard/bidsutils


maindir=`pwd`
baseout=${maindir}/derivatives/fsl/EVfiles
if [ ! -d ${baseout} ]; then
  mkdir -p $baseout
fi

sub=$1
nruns=$2

for run in `seq $nruns`; do
 input=${maindir}/bids/sub-${sub}/func/sub-${sub}_task-ultimatum_run-0${run}_events.tsv
  mkdir -p $output
  if [ -e $input ]; then 	
  	output=${baseout}/sub-${sub}/ultimatum-pmod
   bash /ZPOOL/data/tools/BIDSto3col.sh -h Offer $input ${output}/run-0${run}
   output=${baseout}/sub-${sub}/ultimatum-rt
   bash /ZPOOL/data/tools/BIDSto3col.sh -h response_time $input ${output}/run-0${run}
  else
    echo "PATH ERROR: cannot locate ${input}."
    exit
  fi
done
