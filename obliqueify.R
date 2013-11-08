#### gogdddamnnn
### R<-->AFNI helper functions
setwd("~/PARC_study/Jim_scripts/")
# write.table(sub_prefixes,'subjects2use.txt',row.names=FALSE,col.names=FALSE)
subs_data <- read.table("subjects2use.txt",)
names(subs_data)<- "subject_prefix"
subs <-as.character(subs_data[,1])

overfolder <-"~/PARC_study/scandata_for_analysis/"

for(sub_iter in 1:length(subs)){
  subfolder <- paste(overfolder,subs[sub_iter],sep="")
  setwd(subfolder)
  dir.create("obliqueify")
}

for(sub_iter in 1:length(subs)){
  subfolder <- paste(overfolder,subs[sub_iter],sep="")
  oblique_dir <- paste(subfolder,"/obliqueify/",sep="")
  func_dir <- paste(subfolder,"/func/",sep="")
  anat_dir <- paste(subfolder,"/anat/",sep="")
  
  epi_file <- paste(subs[sub_iter],"_Study_run_1.nii.gz",sep="")
  epi_file_loc <-paste(func_dir,epi_file,sep="")
  
  anat_file <- paste(subs[sub_iter],"_FSPGR_1.nii.gz",sep="")
  anat_file_loc <-paste(anat_dir,anat_file,sep="")
  oblique_anat_prefix <- paste(subs[sub_iter],"_FSPGR_obli",sep="")
  
#   file.copy(epi_file_loc,oblique_dir)
#   file.copy(anat_file_loc,oblique_dir)
  setwd(oblique_dir)
  warp_command <-paste('/Users/Jim/abin/3dWarp -card2oblique ',epi_file,' -prefix ',oblique_anat_prefix,' ',anat_file,sep="")
  system(warp_command)
  cat(subs[sub_iter])
}






# 
# ## vectorize 
# subs_data$subfolder <- paste(overfolder,subs_data$subject_prefix,sep="")
# subs_data$oblique_dir <- paste(subs_data$subfolder,"/obliqueify",sep="")
# subs_data$func_dir <- paste(subs_data$subfolder,"/func",sep="")
# subs_data$anat_dir <- paste(subs_data$subfolder,"/anat",sep="")
# 
# subs_data$epi_file <- paste(subs_data$subject_prefix,"_Study_run_1.nii.gz",sep="")
# subs_data$epi_file_loc <-paste(subs_data$func_dir,"/",subs_data$epi_file,sep="")
# 
# subs_data$anat_file <- paste(subs_data$subject_prefix,"_FSPGR_1.nii.gz",sep="")
# subs_data$anat_file_loc <-paste(subs_data$anat_dir,"/",subs_data$anat_file,sep="")
# subs_data$oblique_anat_prefix <- paste(subs_data$subject_prefix,"_FSPGR_obli",sep="")
# subs <- subs_data$subject_prefix
# 
# file.copy(subs_data$epi_file_loc,subs_data$oblique_dir)
# 
# for(sub_iter in subs){  
#   print(sub_iter)
#   
#   file.copy(subs_data$epi_file_loc[sub_iter],subs_data$oblique_dir[sub_iter])
#   
#   file.copy(subs_data$anat_file_loc[sub_iter],subs_data$oblique_dir[sub_iter])
# }
# 


### ok fucking lets obliquiffy everything
3dWarp -card2oblique $epi_dir/PARC_sub_2699_Study_run_1.nii.gz -prefix PARC_sub_2699_FSPGR_obli PARC_sub_2699_FSPGR_1_nudged.nii

afni_getvols <- function(scanfilename) {  
  x <- paste('/Users/Jim/abin/3dinfo -nv ', scanfilename,sep="")
  blah<-system(x,intern=TRUE)
  blah
}