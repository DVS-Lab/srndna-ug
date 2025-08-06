#!/usr/bin/env bash

# This script performs Level 1 statistics in FSL.
# Merges three analyses into one script:
#   1) activation
#   2) seed-based ppi
#   3) network-based ppi
# Note: activation analysis must be performed first, followed by seed-based and network-based ppi.

# PBS directives for job submission
#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -N L1stats-trust-all
#PBS -q normal
#PBS -m ae
#PBS -M derrick.dwamena@temple.edu
#PBS -l nodes=1:ppn=28

# Load FSL and go to work directory
module load fsl/6.0.2
source $FSLDIR/etc/fslconf/fsl.sh
cd $PBS_O_WORKDIR

# Define paths
srndnadatadir=/home/tut28273/srndna-ug # Update upon release
scriptdir=$srndnadatadir/code
logdir=$srndnadatadir/logs
mkdir -p $logdir

rm -f $logdir/cmd_feat_${PBS_JOBID}.txt
touch $logdir/cmd_feat_${PBS_JOBID}.txt

# Loop through subjects and runs
for sub in ${subjects[@]}; do
    for run in 1 2; do

        # Study-specific inputs
        TASK=ultimatum
        sm=6
        sub=$1
        run=$2
        ppi=$3 # 0 for activation, otherwise seed region or network

        # Set inputs and general outputs
        MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
        mkdir -p $MAINOUTPUT
        DATA=${srndnadatadir}/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${TASK}_run-${run}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
        CONFOUNDEVS=${srndnadatadir}/derivatives/fsl/confounds/sub-${sub}/sub-${sub}_task-${TASK}_run-${run}_desc-fslConfounds.tsv
        if [ ! -e $CONFOUNDEVS ]; then
            echo "missing: $CONFOUNDEVS " >> ${maindir}/re-runL1.log
            exit # Exit if confounds are missing
        fi
        EVDIR=${srndnadatadir}/derivatives/fsl/EVfiles/sub-${sub}/${TASK}-pmod/run-0${run}
        RTEVS=${srndnadatadir}/derivatives/fsl/EVfiles/sub-${sub}/ultimatum-rt/run-0${run}

        # Check for empty EVs
        MISSED_TRIAL=${EVDIR}_missed_trial.txt
        if [ -e $MISSED_TRIAL ]; then
            EV_SHAPE=3
        else
            EV_SHAPE=10
        fi

        # Determine analysis type: network, activation, or seed-based ppi
        if [ "$ppi" == "ecn" -o  "$ppi" == "dmn" ]; then

            # Check for output and skip existing
            OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-02_type-nppi-${ppi}_run-0${run}_sm-${sm}
            if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
                exit
            else
                echo "missing: $OUTPUT " >> ${maindir}/re-runL1.log
                rm -rf ${OUTPUT}.feat
            fi

            # Network extraction
            MASK=${MAINOUTPUT}/L1_task-${TASK}_model-02_type-act_run-0${run}_sm-${sm}.feat/mask
            if [ ! -e ${MASK}.nii.gz ]; then
                echo "cannot run nPPI because you're missing $MASK"
                exit
            fi
            for net in `seq 0 9`; do
                NET=${maindir}/masks/nan_rPNAS_2mm_net000${net}.nii.gz
                TSFILE=${MAINOUTPUT}/ts_task-${TASK}_net000${net}_nppi-${ppi}_run-0${run}.txt
                fsl_glm -i $DATA -d $NET -o $TSFILE --demean -m $MASK
                eval INPUT${net}=$TSFILE
            done

            # Set network ppi names
            DMN=$INPUT3
            ECN=$INPUT7
            if [ "$ppi" == "dmn" ]; then
                MAINNET=$DMN
                OTHERNET=$ECN
            else
                MAINNET=$ECN
                OTHERNET=$DMN
            fi

            # Create template and run analyses
            ITEMPLATE=${maindir}/templates/L1_task-${TASK}_model-02_type-nppi.fsf
            OTEMPLATE=${MAINOUTPUT}/L1_task-${TASK}_model-02_seed-${ppi}_run-0${run}.fsf
            sed -e 's@OUTPUT@'$OUTPUT'@g' \
                -e 's@DATA@'$DATA'@g' \
                -e 's@EVDIR@'$EVDIR'@g' \
                -e 's@MISSED_TRIAL@'$MISSED_TRIAL'@g' \
                -e 's@EV_SHAPE@'$EV_SHAPE'@g' \
                -e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
                -e 's@MAINNET@'$MAINNET'@g' \
                -e 's@OTHERNET@'$OTHERNET'@g' \
                -e 's@INPUT0@'$INPUT0'@g' \
                -e 's@INPUT1@'$INPUT1'@g' \
                -e 's@INPUT2@'$INPUT2'@g' \
                -e 's@INPUT4@'$INPUT4'@g' \
                -e 's@INPUT5@'$INPUT5'@g' \
                -e 's@INPUT6@'$INPUT6'@g' \
                -e 's@INPUT8@'$INPUT8'@g' \
                -e 's@INPUT9@'$INPUT9'@g' \
                -e 's@RTEVS@'$RTEVS'@g' \
                <$ITEMPLATE> $OTEMPLATE
            feat $OTEMPLATE

        else # Activation or seed-based ppi

            # Set output based on activation or ppi
            if [ "$ppi" == "0" ]; then
                TYPE=act
                OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-02_type-${TYPE}_run-0${run}_sm-${sm}
            else
                TYPE=ppi
                OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-02_type-${TYPE}_seed-${ppi}_run-0${run}_sm-${sm}
            fi

            # Check for output and skip existing
            if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
                exit
            else
                echo "missing: $OUTPUT " >> ${maindir}/re-runL1.log
                rm -rf ${OUTPUT}.feat
            fi

            # Create template and run analyses
            ITEMPLATE=${maindir}/templates/L1_task-${TASK}_model-02_type-${TYPE}.fsf
            OTEMPLATE=${MAINOUTPUT}/L1_sub-${sub}_task-${TASK}_model-02_seed-${ppi}_run-0${run}.fsf
            if [ "$ppi" == "0" ]; then
                sed -e 's@OUTPUT@'$OUTPUT'@g' \
                    -e 's@DATA@'$DATA'@g' \
                    -e 's@EVDIR@'$EVDIR'@g' \
                    -e 's@MISSED_TRIAL@'$MISSED_TRIAL'@g' \
                    -e 's@EV_SHAPE@'$EV_SHAPE'@g' \
                    -e 's@SMOOTH@'$sm'@g' \
                    -e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
                    -e 's@RTEVS@'$RTEVS'@g' \
                    <$ITEMPLATE> $OTEMPLATE
            else
                PHYS=${MAINOUTPUT}/ts_task-${TASK}_mask-${ppi}_run-0${run}.txt
                MASK=${maindir}/masks/seed-${ppi}_trust.nii.gz
                fslmeants -i $DATA -o $PHYS -m $MASK
                sed -e 's@OUTPUT@'$OUTPUT'@g' \
                    -e 's@DATA@'$DATA'@g' \
                    -e 's@EVDIR@'$EVDIR'@g' \
                    -e 's@MISSED_TRIAL@'$MISSED_TRIAL'@g' \
                    -e 's@EV_SHAPE@'$EV_SHAPE'@g' \
                    -e 's@PHYS@'$PHYS'@g' \
                    -e 's@SMOOTH@'$sm'@g' \
                    -e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
                    -e 's@RTEVS@'$RTEVS'@g' \
                    <$ITEMPLATE> $OTEMPLATE
            fi
            feat $OTEMPLATE
        fi

        # Add feat command to submission script
        echo feat $OTEMPLATE >> $logdir/cmd_feat_${PBS_JOBID}.txt

    done
done

# Launch Torque for batch processing
torque-launch -p $logdir/chk_feat_${PBS_JOBID}.txt $logdir/cmd_feat_${PBS_JOBID}.txt

# Fix registration issues
mkdir -p ${OUTPUT}.feat/reg
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
ln -s ${OUTPUT}.feat/mean_func.nii.gz ${OUTPUT}.feat/reg/standard.nii.gz

# Delete unused files
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
