aggregate_studyfiles_PARC<-function(sub,nblocks){
#   Function to aggregate matlab reulsts files (so can get timings)
  
  
  # final test data 
  behavefinal<-list()
  
  behavefinal$loc<-"/Users/Jim/Dropbox/PARC_Scan_behavioralfiles/final_test_data/"
  behavefinal$files<-dir(behavefinal$loc)
  behavefinal$files <- grep('*correct',behavefinal$files,value=TRUE)
  behavefinal$sub_file_name <- grep(sub,behavefinal$files,value=TRUE)
  
  # read final test list file to get trials etc...
  sub_finalfile <- read.delim(paste(behavefinal$loc,behavefinal$sub_file_name,sep="/"))
  sub_finalfile$stim_type <- substr(as.character(sub_finalfile$condkey),1,1)
  sub_finalfile$stim_type <- factor(as.numeric(sub_finalfile$stim_type=='F') + 2*as.numeric(sub_finalfile$stim_type=='P'),labels=list('face','place'))
  sub_finalfile$reward <- substr(as.character(sub_finalfile$condkey),2,2)
  sub_finalfile$reward <- factor(as.numeric(sub_finalfile$reward=='N') + 2*as.numeric(sub_finalfile$reward=='R'),labels=list('low','high'))
  
  ### scanner data
  # to get timing files
  
  ### get all of subject data in one place. 
  behavscanner <- list()
  behavscanner$loc <- "/Users/Jim/Dropbox/PARC_Scan_behavioralfiles/"
  behavscanner$files <- dir(behavscanner$loc)
  behavscanner$files <- grep(sub,behavscanner$files,value=TRUE)
  behavscanner$sub_test_files <- sort(grep('*_test_block\\d_scrubbed.mat',behavscanner$files,value=TRUE))
  behavscanner$sub_study_files <- sort(grep('*_study_block\\d_study.mat',behavscanner$files,value=TRUE))
  
  setwd(behavscanner$loc)
  
  ### read in study data
  uber_study <- matreaderPARC(behavscanner$sub_study_files[1]) #works cause sorted above
  for(block in 1:nblocks){
    print(block)
    matlab_file <- matreaderPARC(behavscanner$sub_study_files[block])
    uber_study[uber_study$block==block,] <- matlab_file[matlab_file$block==block,] 
  }
  uber_study$Subject <- sub
  return(uber_study)
}


