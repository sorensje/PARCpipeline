### get subject list
subs <- read.csv('~/PARC_study/scandata_raw/sub_exam_list.csv')
subs <- read.csv('~/PARC_study/scandata_raw/sub_exam_list2.csv')
# put in gunzip line here

## how many subject dirs are there? 
scan_raw_overfolder<-"~/PARC_study/scandata_raw/nims/iang/parc/"
setwd(scan_raw_overfolder)
subdirs <- dir()

### where should new shit go

scan_analysis_overfolder <-"~/PARC_study/scandata_for_analysis/" 
setwd(scan_analysis_overfolder)
subdirpossibilities <- paste("PARC_sub_",subs$Subject,sep="")
alreadymade <- dir()
tomake <- setdiff(factor(subdirpossibilities),factor(alreadymade))
if(length(tomake)>0){
  for( ii in 1:length(tomake)){
    dir.create(tomake[ii])
    dir.create(paste(tomake[ii],"/anat",sep=""))
    dir.create(paste(tomake[ii],"/func",sep=""))
  }  
  rm(ii)
}

for( ii in 1:length(subdirs)){
  sub_overfolder <- paste(scan_raw_overfolder,subdirs[ii],sep="")
  setwd(sub_overfolder)
  
  scandirs<-list.dirs(full.names=FALSE)
  scandirs<-scandirs[-1] # get rid of "./" dir
  scandirs<-gsub("./","",scandirs)
  
  # which scans are EPI
  ## scans should be 5...16, but just in case...
  EPI_scans<-scandirs[grep("EPI",scandirs)]
  blahlist <- lapply(EPI_scans,substr,1,2)
  nums <- gsub("_","",blahlist)
  nums <- sort(as.numeric(nums))
  EPIscans_not_anticipated_number<- setdiff(nums,5:16) # catch surprises
  total_epis<-length(EPI_scans)

  
  #move EPIS
  for (jj in 1:length(EPI_scans)){

    study_or_test_jj <- ifelse(jj %% 2 ==1,yes='Study','Test')
    run_jj <- ceiling(jj/2)  
    epi_jj<-grep(paste("^",nums[jj],"_",sep=""),EPI_scans,value=TRUE)
    epi_dir_jj <- paste(sub_overfolder,epi_jj,sep="/")
    setwd(epi_dir_jj)
    scanfiles_jj <- dir()
    exam_jj<-substr(scanfiles_jj[1],1,4)
    subj_jj <- subs[subs$Exam==exam_jj,'Subject']
    new_epi_name <- paste("PARC_sub_",subj_jj,"_",study_or_test_jj,"_run_",run_jj,".nii.gz",sep="")
    ##
#     print(subj_jj)
    rawfile <- grep(".nii",scanfiles_jj,value=TRUE)
    rawloc<-paste(epi_dir_jj,rawfile,sep="/")
    newloc<-paste(scan_analysis_overfolder,"PARC_sub_",subj_jj,"/func/",new_epi_name,sep="")
    file.copy(from=rawloc,to=newloc)
  }
  print(subj_jj)
  # indentify & move anats
  inplanes <- grep("Inplane",scandirs,value=TRUE)
  blahlist <- lapply(inplanes,substr,1,2)
  nums <- gsub("_","",blahlist)
  nums <- sort(as.numeric(nums))
  
  for(jj in 1:length(inplanes)){
    inplane_ii <- grep(paste("^",nums[jj],"_",sep=""),inplanes,value=TRUE)
    new_inplane_name <- paste("PARC_sub_",subj_jj,"_","inplane_",jj,".nii.gz",sep="")
    inplanedir <-  paste(sub_overfolder,inplane_ii,sep="/")
    inplane_file <- dir(inplanedir,pattern="*.nii.gz")
    rawloc<-paste(inplanedir,inplane_file,sep="/")
    newloc<-paste(scan_analysis_overfolder,"PARC_sub_",subj_jj,"/anat/",new_inplane_name,sep="")
    file.copy(from=rawloc,to=newloc)
  }
    
    fspgrs <- grep("FSPGR",scandirs,value=TRUE)
    blahlist <- lapply(fspgrs,substr,1,2)
    nums <- gsub("_","",blahlist)
    nums <- sort(as.numeric(nums))
  
  for(jj in 1:length(fspgrs)){
    FSPGR_ii <- grep(paste("^",nums[jj],"_",sep=""),fspgrs,value=TRUE)
    new_FSPGR_name <- paste("PARC_sub_",subj_jj,"_","FSPGR_",jj,".nii.gz",sep="")
    FSPGRdir <-  paste(sub_overfolder,FSPGR_ii,sep="/")
    FSPGR_file <- dir(FSPGRdir,pattern="*.nii.gz")
    rawloc<-paste(FSPGRdir,FSPGR_file,sep="/")
    newloc<-paste(scan_analysis_overfolder,"PARC_sub_",subj_jj,"/anat/",new_FSPGR_name,sep="")
    file.copy(from=rawloc,to=newloc)
  }
  
  #checks

  cat(subj_jj,"EPIscans not anticipated:",EPIscans_not_anticipated_number,"total EPIs:",total_epis, "n inplanes",length(inplanes)," n FSPGR", length(fspgrs),'\n')

}


  
