#### make timing vectors for analysis
#important shit happens at line 90

# function(TRstodrop,TRlength,Subject,conditions)


#get necessary files
source("~/PARC_study/Jim_scripts/pipeline/read_behavioral_files.R") #read in behavioral files
source("/Users/Jim/PARC_study/Jim_scripts/binarytimingvector.R")
source("/Users/Jim/PARC_study/Jim_scripts/nearestTR.R")

setwd("~/PARC_study/scandata_for_analysis/")


# variables specific to 
# sub <- 
TRstodrop<-3
TRlength<-2
rewardtime <- 1.6 #seconds
stim_time <- 6 # seconds
condition <- "finaltest_correct"
overfolder <-"~/PARC_study/scandata_for_analysis/"

### change later
subs <- unique(study_finalcorrect$Subject)
sub_prefixes <- paste("PARC_sub_",subs,sep="")

# for(sub_iter in 1:length(subs)){
#   subfolder <- paste(overfolder,"PARC_sub_",subs[sub_iter],sep="")
#   setwd(subfolder)
#   dir.create("afni_files")
# }
# subs<-2699

for(sub_iter in 1:length(subs)){
  
  # set subject specific files
  subject <- subs[sub_iter]
  sub_prefix<-paste("PARC_sub_",subs[sub_iter],sep="")
  subfolder <- paste(overfolder,"PARC_sub_",subject,"/afni_files",sep="")
  setwd(subfolder)
  
  sub_data <- study_finalcorrect[study_finalcorrect$Subject==subject,]
  sub_data <- sub_data[sort(sub_data$index),]
  
  ##### use scanner start time to calculate onsets/offsets!
  sub_data$onset_fromscannerstart<-sub_data$onsetRaw-sub_data$scannerstart
  sub_data$offset_fromscannerstart<-sub_data$offsetRaw-sub_data$scannerstart
  
  # drop how ever many seconds worth of TRs we're dropping
  sub_data$trial_onset_trim <-sub_data$onset_fromscannerstart-(TRstodrop*TRlength) 
  sub_data$trial_offset_trim <- sub_data$offset_fromscannerstart-(TRstodrop*TRlength)
  
  sub_data$reward_onset <- sub_data$trial_onset_trim 
  sub_data$encode_onset_trim <- sub_data$trial_onset_trim + rewardtime + sub_data$RwdIntFix
  sub_data$encode_onset_trim <- round(sub_data$encode_onset_trim,1)
  sub_data$trial_duration <-rewardtime + sub_data$RwdIntFix +stim_time +sub_data$PostFix
  
  # make global onsets 
  
  ## global onsets 
  sub_data$global_onset <- sub_data$trial_onset_trim #just to initialize
  n_trials <- max(sub_data$trial)
  for( trial_iter in 2:n_trials){
    sub_data$global_onset[trial_iter] <- sub_data$global_onset[trial_iter-1]+ sub_data$trial_duration[trial_iter-1]
  }
  
  ## get duration of blocks (not necessary anymore?)
  n_blocks <- length(unique(sub_data$block))
  max_time_run <- rep(0,n_blocks)
  block_onset_global <- rep(0,n_blocks)
  for (iter_block in 1: n_blocks){
    runtrials <- sub_data[sub_data$block==iter_block,'trial']
    last_trial <- max(runtrials)
    first_trial<- min(runtrials)
    max_time_run[iter_block] <- sub_data[sub_data$trial==last_trial,'trial_onset_trim']+ sub_data[sub_data$trial==last_trial,'trial_duration']
    block_onset_global[iter_block] <- sub_data[sub_data$trial==first_trial,'global_onset']
  }
  
  # create vectors for later getting total time/TR info
  max_time_run_TR <- nearestTR(max_time_run,TRlength) #round to 2 sec
  total_time <- sum(max_time_run)
  total_time_TR <- nearestTR(total_time,TRlength)
    
  # block_onset_global <- round(block_onset_global/1000,0)
  block_onset_global_TR <- nearestTR(block_onset_global,TRlength)
  
  
  
  
  ### make correct stim file ####
  filename_correc_encode <- paste(sub_prefix,"_correct_encode_allblocks.txt",sep="")
  correct_encode_onsets <- list()
  for (iter_block in 1: n_blocks){
     encode_onsets_iter <- sub_data[sub_data$block==iter_block & sub_data$finaltest_correct=='1','encode_onset_trim']
     if(length(encode_onsets_iter) >0){
       correct_encode_onsets[[iter_block]] <- encode_onsets_iter
     }else (correct_encode_onsets[[iter_block]] <-"*") #necessary for empty blocks
  }    
       
  # write seperately
  sink(file=filename_correc_encode)
  for (iter_block in 1: n_blocks){
    cat(correct_encode_onsets[[iter_block]],"\n",sep=" ")
  }
  sink(file=NULL)
  
  
  ### make miss stim file ####
  filename_correc_encode <- paste(sub_prefix,"_miss_encode_allblocks.txt",sep="")
  miss_encode_onsets <- list()
  for (iter_block in 1: n_blocks){
    encode_onsets_iter <- sub_data[sub_data$block==iter_block & sub_data$finaltest_correct=='0','encode_onset_trim']
    if(length(encode_onsets_iter) >0){
      miss_encode_onsets[[iter_block]] <- encode_onsets_iter
    }else (miss_encode_onsets[[iter_block]] <-"*") #necessary for empty blocks
  }    
  
  # write seperately
  sink(file=filename_correc_encode)
  for (iter_block in 1: n_blocks){
    cat(miss_encode_onsets[[iter_block]],"\n",sep=" ")
  }
  sink(file=NULL)
  
  #write run lengths
  filename_block_onset_global_TR <-  paste(sub_prefix,"_onset_global_TR_study.txt",sep="")
  filename_total_time_TR <-  paste(sub_prefix,"_total_TR_study.txt",sep="")  
  write.table(t(block_onset_global_TR),filename_block_onset_global_TR, row.names=FALSE, col.names = FALSE)
  write.table(total_time_TR,filename_total_time_TR, row.names=FALSE, col.names = FALSE)
    
}
  



