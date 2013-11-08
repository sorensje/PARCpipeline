aggregate_testfiles_PARC<-function(sub,nblocks){
  # must run Rfilewriter_PARC_Scan__combine_tests3 first 
  
  
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
  
  uber_test <- matreaderPARC_debugged(behavscanner$sub_test_files[1]) #works cause sorted above
  for(block in 1:nblocks){
    #   matlab_file <- matreaderPARC2(behavscanner$sub_test_files[block])
    matlab_file <- matreaderPARC_debugged(behavscanner$sub_test_files[block])
    uber_test[uber_test$block==block,] <- matlab_file[matlab_file$block==block,]
    print(block)
  }
  uber_test$Subject <- sub
  return(uber_test)
}

