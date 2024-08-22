# example code for FMRIPREP
# runs FMRIPREP on input subject
# usage: bash run_fmriprep.sh sub
# example: bash run_fmriprep.sh 102

sub=$1

# set up input and output directories.
maindir=`pwd` # assume you are running from the root

# make derivatives folder if it doesn't exist.
# let's keep this out of bids for now
if [ ! -d $maindir/derivatives ]; then
	mkdir -p $maindir/derivatives
fi

scratchdir=/data/scratch/`whoami`
if [ ! -d $scratchdir ]; then
	mkdir -p $scratchdir
fi

singularity run --cleanenv -B $maindir:/base -B /data/tools/licenses:/opts -B $scratchdir:/scratch \
/data/tools/fmriprep-23.2.1.simg \
/base/bids /base/derivatives \
participant --participant_label $sub \
-t ultimatum \
--stop-on-first-crash \
--output-spaces MNI152NLin6Asym \
--fs-no-reconall --fs-license-file /opts/fs_license.txt -w /scratch
