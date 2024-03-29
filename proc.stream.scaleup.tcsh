#!/bin/tcsh -xef

echo "auto-generated by afni_proc.py, Tue Oct 29 13:56:46 2013"
echo "(version 3.43, April 15, 2013)"

# execute via : 
#   tcsh -xef proc.stream.tcsh PARC_sub_2754 |& tee output.proc.PARC_sub_2754

# =========================== auto block: setup ============================
# script setup

# take note of the AFNI version
afni -ver

# check that the current AFNI version is recent enough
afni_history -check_date 1 Apr 2013
if ( $status ) then
    echo "** this script requires newer AFNI binaries (than 1 Apr 2013)"
    echo "   (consider: @update.afni.binaries -defaults)"
    exit
endif

# the user may specify a single subject to run with
if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = PARC_sub_2718
endif

# assign output directory name
set output_dir = $subj.results

# verify that the results directory does not yet exist
if ( -d $output_dir ) then
    echo output dir "$subj.results" already exists
    exit
endif

# set list of runs
set runs = (`count -digits 2 1 6`)

# create results and stimuli directories
mkdir $output_dir
mkdir $output_dir/stimuli

# copy stim files into stimulus directory
cp                                                                                                                  \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/afni_files/${subj}_correct_encode_allblocks.txt \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/afni_files/${subj}_miss_encode_allblocks.txt    \
    $output_dir/stimuli

# copy anatomy to results dir
3dcopy                                                                                                 \
    /Users/Jim/PARC_study/maybe_fixed/${subj/anat/${subj}_FSPGR_1.nii.gz \
    $output_dir/${subj}_FSPGR

# ============================ auto block: tcat ============================
# apply 3dTcat to copy input dsets to results dir, while
# removing the first 3 TRs
3dTcat -prefix $output_dir/pb00.$subj.r01.tcat                              \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_1.nii.gz'[3..$]'
3dTcat -prefix $output_dir/pb00.$subj.r02.tcat                              \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_2.nii.gz'[3..$]'
3dTcat -prefix $output_dir/pb00.$subj.r03.tcat                              \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_3.nii.gz'[3..$]'
3dTcat -prefix $output_dir/pb00.$subj.r04.tcat                              \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_4.nii.gz'[3..$]'
3dTcat -prefix $output_dir/pb00.$subj.r05.tcat                              \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_5.nii.gz'[3..$]'
3dTcat -prefix $output_dir/pb00.$subj.r06.tcat                              \
    /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_6.nii.gz'[3..$]'

# and make note of repetitions (TRs) per run
# set tr_counts = ( 125 121 125 125 131 125 )


# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir


# ========================== auto block: outcount ==========================
# data check: compute outlier fraction for each volume
touch out.pre_ss_warn.txt
foreach run ( $runs )
    3dToutcount -automask -fraction -polort 2 -legendre                     \
                pb00.$subj.r$run.tcat+orig > outcount.r$run.1D

    # outliers at TR 0 might suggest pre-steady state TRs
    if ( `1deval -a outcount.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
        echo "** TR #0 outliers: possible pre-steady state TRs in run $run" \
            >> out.pre_ss_warn.txt
    endif
end

# catenate outlier counts into a single time series
cat outcount.r*.1D > outcount_rall.1D

# ================================= tshift =================================
# time shift data so all slice timing is the same 
foreach run ( $runs )
    3dTshift -tzero 0 -quintic -prefix pb01.$subj.r$run.tshift \
             pb00.$subj.r$run.tcat+orig
end

# ================================= count trs =================================
touch tr_Counts.txt
foreach run ( $runs )
  3dinfo -nv pb01.$subj.r$run.tshift+orig >> tr_Counts.txt
end
set tr_counts = `cat tr_Counts.txt`


# ================================= deoblique ========
foreach run ( $runs )
	3dWarp -oblique2card -prefix pb01.$subj.r$run.card_tshift \
	pb01.$subj.r$run.tshift+orig
end

# ================================= align ==================================
# for e2a: compute anat alignment transformation to EPI registration base
# (new anat will be intermediate, stripped, ${subj}_FSPGR_ns+orig)
align_epi_anat.py -anat2epi -anat ${subj}_FSPGR+orig \
       -save_skullstrip -suffix _al_junk                        \
       -epi pb01.$subj.r01.card_tshift+orig -epi_base 0              \
       -volreg off -tshift off

# ================================== tlrc ==================================
# warp anatomy to standard space
@auto_tlrc -base TT_N27+tlrc -input ${subj}_FSPGR_ns+orig -no_ss \
    -suffix NONE

# ================================= volreg =================================
# align each dset to base volume, align to anat, warp to tlrc space

# verify that we have a +tlrc warp dataset
if ( ! -f ${subj}_FSPGR_ns+tlrc.HEAD ) then
    echo "** missing +tlrc warp dataset:                            \
        ${subj}_FSPGR_ns+tlrc.HEAD" 
    exit
endif

# create an all-1 dataset to mask the extents of the warp
3dcalc -a pb01.$subj.r01.card_tshift+orig -expr 1 -prefix rm.epi.all1

# register and warp
foreach run ( $runs )
    # register each volume to the base
    3dvolreg -verbose -zpad 1 -base pb01.$subj.r$run.card_tshift+orig'[0]' \
             -1Dfile dfile.r$run.1D -prefix rm.epi.volreg.r$run     \
             -cubic                                                 \
             -1Dmatrix_save mat.r$run.vr.aff12.1D                   \
             pb01.$subj.r$run.card_tshift+orig

    # catenate volreg, epi2anat and tlrc transformations
    cat_matvec -ONELINE                                             \
               ${subj}_FSPGR_ns+tlrc::WARP_DATA -I       \
               ${subj}_FSPGR_al_junk_mat.aff12.1D -I     \
               mat.r$run.vr.aff12.1D > mat.r$run.warp.aff12.1D

    # apply catenated xform : volreg, epi2anat and tlrc
    3dAllineate -base ${subj}_FSPGR_ns+tlrc              \
                -input pb01.$subj.r$run.card_tshift+orig            \
                -1Dmatrix_apply mat.r$run.warp.aff12.1D             \
                -mast_dxyz 3                                        \
                -prefix rm.epi.nomask.r$run 

    # warp the all-1 dataset for extents masking 
    3dAllineate -base ${subj}_FSPGR_ns+tlrc              \
                -input rm.epi.all1+orig                             \
                -1Dmatrix_apply mat.r$run.warp.aff12.1D             \
                -mast_dxyz 3 -final NN -quiet                       \
                -prefix rm.epi.1.r$run 

    # make an extents intersection mask of this run
    3dTstat -min -prefix rm.epi.min.r$run rm.epi.1.r$run+tlrc
end

# make a single file of registration params
cat dfile.r*.1D > dfile_rall.1D

# ----------------------------------------
# create the extents mask: mask_epi_extents+tlrc
# (this is a mask of voxels that have valid data at every TR)
3dMean -datum short -prefix rm.epi.mean rm.epi.min.r*.HEAD 
3dcalc -a rm.epi.mean+tlrc -expr 'step(a-0.999)' -prefix mask_epi_extents

# and apply the extents mask to the EPI data 
# (delete any time series with missing data)
foreach run ( $runs )
    3dcalc -a rm.epi.nomask.r$run+tlrc -b mask_epi_extents+tlrc     \
           -expr 'a*b' -prefix pb02.$subj.r$run.volreg
end

# create an anat_final dataset, aligned with stats
3dcopy ${subj}_FSPGR_ns+tlrc anat_final.$subj

# ================================== blur ==================================
# blur each volume of each run
foreach run ( $runs )
    3dmerge -1blur_fwhm 4.0 -doall -prefix pb03.$subj.r$run.blur \
            pb02.$subj.r$run.volreg+tlrc
end

# ================================== mask ==================================
# create 'full_mask' dataset (union mask)
foreach run ( $runs )
    3dAutomask -dilate 1 -prefix rm.mask_r$run pb03.$subj.r$run.blur+tlrc
end

# get mean and compare it to 0 for taking 'union'
3dMean -datum short -prefix rm.mean rm.mask*.HEAD
3dcalc -a rm.mean+tlrc -expr 'ispositive(a-0)' -prefix full_mask.$subj

# ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
#      (resampled from tlrc anat)
3dresample -master full_mask.$subj+tlrc -input                        \
           ${subj}_FSPGR_ns+tlrc                           \
           -prefix rm.resam.anat

# convert to binary anat mask; fill gaps and holes
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc  \
            -prefix mask_anat.$subj

# compute overlaps between anat and EPI masks
3dABoverlap -no_automask full_mask.$subj+tlrc mask_anat.$subj+tlrc    \
            |& tee out.mask_overlap.txt

# ---- create group anatomy mask, mask_group+tlrc ----
#      (resampled from tlrc base anat, TT_N27+tlrc)
3dresample -master full_mask.$subj+tlrc -prefix ./rm.resam.group      \
           -input /Users/Jim/abin/TT_N27+tlrc

# convert to binary group mask; fill gaps and holes
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.group+tlrc \
            -prefix mask_group

# ================================= scale ==================================
# scale each voxel time series to have a mean of 100
# (be sure no negatives creep in)
# (subject to a range of [0,200])
foreach run ( $runs )
    3dTstat -prefix rm.mean_r$run pb03.$subj.r$run.blur+tlrc
    3dcalc -a pb03.$subj.r$run.blur+tlrc -b rm.mean_r$run+tlrc \
           -c mask_epi_extents+tlrc                            \
           -expr 'c * min(200, a/b*100)*step(a)*step(b)'       \
           -prefix pb04.$subj.r$run.scale
end

# ================================ regress =================================

# compute de-meaned motion parameters (for use in regression)
1d_tool.py -infile dfile_rall.1D -set_run_lengths ${tr_counts}  \
           -demean -write motion_demean.1D

# compute motion parameter derivatives (just to have)
1d_tool.py -infile dfile_rall.1D -set_run_lengths ${tr_counts}  \
           -derivative -demean -write motion_deriv.1D

# create censor file motion_${subj}_censor.1D, for censoring motion 
1d_tool.py -infile dfile_rall.1D -set_run_lengths ${tr_counts}  \
    -show_censor_count -censor_prev_TR                                     \
    -censor_motion 0.3 motion_${subj}

# run the regression analysis
3dDeconvolve -input pb04.$subj.r*.scale+tlrc.HEAD                          \
    -censor motion_${subj}_censor.1D                                       \
    -polort 2                                                              \
    -num_stimts 8                                                          \
    -stim_times 1 stimuli/${subj}_correct_encode_allblocks.txt       \
    'BLOCK(6,1)'                                                           \
    -stim_label 1 correct_encode_allblocks                                 \
    -stim_times 2 stimuli/${subj}_miss_encode_allblocks.txt          \
    'BLOCK(6,1)'                                                           \
    -stim_label 2 miss_encode_allblocks                                    \
    -stim_file 3 motion_demean.1D'[0]' -stim_base 3 -stim_label 3 roll     \
    -stim_file 4 motion_demean.1D'[1]' -stim_base 4 -stim_label 4 pitch    \
    -stim_file 5 motion_demean.1D'[2]' -stim_base 5 -stim_label 5 yaw      \
    -stim_file 6 motion_demean.1D'[3]' -stim_base 6 -stim_label 6 dS       \
    -stim_file 7 motion_demean.1D'[4]' -stim_base 7 -stim_label 7 dL       \
    -stim_file 8 motion_demean.1D'[5]' -stim_base 8 -stim_label 8 dP       \
    -gltsym 'SYM: correct_encode_allblocks -miss_encode_allblocks'         \
    -glt_label 1 C-M                                                       \
    -gltsym 'SYM: 0.5*correct_encode_allblocks +0.5*miss_encode_allblocks' \
    -glt_label 2 mean.CM                                                   \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                                \
    -x1D_uncensored X.nocensor.xmat.1D                                     \
    -fitts fitts.$subj                                                     \
    -errts errts.${subj}                                                   \
    -bucket stats.$subj


# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
endif


# display any large pariwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile X.xmat.1D |& tee out.cormat_warn.txt

# create an all_runs dataset to match the fitts, errts, etc.
3dTcat -prefix all_runs.$subj pb04.$subj.r*.scale+tlrc.HEAD

# create a temporal signal to noise ratio dataset 
#    signal: if 'scale' block, mean should be 100
#    noise : compute standard deviation of errts
3dTstat -mean -prefix rm.signal.all all_runs.$subj+tlrc
3dTstat -stdev -prefix rm.noise.all errts.${subj}+tlrc
3dcalc -a rm.signal.all+tlrc                                               \
       -b rm.noise.all+tlrc                                                \
       -c full_mask.$subj+tlrc                                             \
       -expr 'c*a/b' -prefix TSNR.$subj 

# compute and store GCOR (global correlation average)
# - compute as sum of squares of global mean of unit errts
3dTnorm -prefix rm.errts.unit errts.${subj}+tlrc
3dmaskave -quiet -mask full_mask.$subj+tlrc rm.errts.unit+tlrc >           \
    gmean.errts.unit.1D
3dTstat -sos -prefix - gmean.errts.unit.1D\' > out.gcor.1D
echo "-- GCOR = `cat out.gcor.1D`"

# create ideal files for fixed response stim types
1dcat X.nocensor.xmat.1D'[18]' > ideal_correct_encode_allblocks.1D
1dcat X.nocensor.xmat.1D'[19]' > ideal_miss_encode_allblocks.1D

# compute sum of non-baseline regressors from the X-matrix
# (use 1d_tool.py to get list of regressor colums)
set reg_cols = `1d_tool.py -infile X.nocensor.xmat.1D -show_indices_interest`
3dTstat -sum -prefix sum_ideal.1D X.nocensor.xmat.1D"[$reg_cols]"

# also, create a stimulus-only X-matrix, for easy review
1dcat X.nocensor.xmat.1D"[$reg_cols]" > X.stim.xmat.1D

# ============================ blur estimation =============================
# compute blur estimates
touch blur_est.$subj.1D   # start with empty file

# -- estimate blur for each run in epits --
touch blur.epits.1D

set b0 = 0     # first index for current run
set b1 = -1    # will be last index for current run
foreach reps ( $tr_counts )
    @ b1 += $reps  # last index for current run
    3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
        all_runs.$subj+tlrc"[$b0..$b1]" >> blur.epits.1D
    @ b0 += $reps  # first index for next run
end

# compute average blur and append
set blurs = ( `3dTstat -mean -prefix - blur.epits.1D\'` )
echo average epits blurs: $blurs
echo "$blurs   # epits blur estimates" >> blur_est.$subj.1D

# -- estimate blur for each run in errts --
touch blur.errts.1D

set b0 = 0     # first index for current run
set b1 = -1    # will be last index for current run
foreach reps ( $tr_counts )
    @ b1 += $reps  # last index for current run
    3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
        errts.${subj}+tlrc"[$b0..$b1]" >> blur.errts.1D
    @ b0 += $reps  # first index for next run
end

# compute average blur and append
set blurs = ( `3dTstat -mean -prefix - blur.errts.1D\'` )
echo average errts blurs: $blurs
echo "$blurs   # errts blur estimates" >> blur_est.$subj.1D


# add 3dClustSim results as attributes to the stats dset
set fxyz = ( `tail -1 blur_est.$subj.1D` )
3dClustSim -both -NN 123 -mask full_mask.$subj+tlrc                        \
           -fwhmxyz $fxyz[1-3] -prefix ClustSim
3drefit -atrstring AFNI_CLUSTSIM_MASK file:ClustSim.mask                   \
        -atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.NN1.niml               \
        -atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.NN2.niml               \
        -atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.NN3.niml               \
        stats.$subj+tlrc


# ================== auto block: generate review scripts ===================

# generate a review script for the unprocessed EPI data
gen_epi_review.py -script @epi_review.$subj \
    -dsets pb00.$subj.r*.tcat+orig.HEAD

# generate scripts to review single subject results
# (try with defaults, but do not allow bad exit status)
gen_ss_review_scripts.py -mot_limit 0.3 -exit0

# ========================== auto block: finalize ==========================

# remove temporary files
\rm -f rm.*

# if the basic subject review script is here, run it
# (want this to be the last text output)
if ( -e @ss_review_basic ) ./@ss_review_basic |& tee out.ss_review.$subj.txt

# return to parent directory
cd ..




# ==========================================================================
# script generated by the command:
#
# afni_proc.py -subj_id ${subj} -script proc.${subj}                                                      \
#     -scr_overwrite -blocks tshift align tlrc volreg blur mask scale regress                                         \
#     -copy_anat                                                                                                      \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/obliqueify/${subj}_FSPGR+orig              \
#     -tcat_remove_first_trs 3 -dsets                                                                                 \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_1.nii.gz                 \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_2.nii.gz                 \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_3.nii.gz                 \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_4.nii.gz                 \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_5.nii.gz                 \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/func/${subj}_Study_run_6.nii.gz                 \
#     -volreg_align_to first -volreg_align_e2a -volreg_tlrc_warp -blur_size                                           \
#     4.0 -regress_stim_times                                                                                         \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/afni_files/${subj}_correct_encode_allblocks.txt \
#     /Users/Jim/PARC_study/scandata_for_analysis/${subj}/afni_files/${subj}_miss_encode_allblocks.txt    \
#     -regress_stim_labels correct_encode_allblocks miss_encode_allblocks                                             \
#     -regress_basis 'BLOCK(6,1)' -regress_censor_motion 0.3                                                          \
#     -regress_opts_3dD -gltsym 'SYM: correct_encode_allblocks                                                        \
#     -miss_encode_allblocks' -glt_label 1 C-M -gltsym 'SYM:                                                          \
#     0.5*correct_encode_allblocks +0.5*miss_encode_allblocks' -glt_label 2                                           \
#     mean.CM -regress_make_ideal_sum sum_ideal.1D -regress_est_blur_epits                                            \
#     -regress_est_blur_errts
