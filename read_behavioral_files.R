#### read in behavioral files 
# return bothtest: test data w/ posttest info
# return study_finalcorrect: test data w/ posttest info

setwd("~/PARC_study/behavioral_data/")

### read in files

#study
studytdat <- read.csv("all_sub_study.csv")
str(studytdat)
studytdat$trial <- studytdat$index
studytdat$Subject <- factor(studytdat$Subject)
if (studytdat$PostFix[1] %%1 ==.4){
  names(studytdat) <- c('index','block','condkey','cond','wordName','imgName','imgFile','imgType','subType','RwdIntFix','PostFix','sub','onsetRaw','onsetCalculated','offsetRaw','offsetCalculated','trialLength','scannerstart','blockstart','Subject','trial')
}
studytdat$study_trial <- studytdat$trial

#test
test_dat <- read.csv("all_sub_test.csv")
str(test_dat)
test_dat$test_trial <- test_dat$index
test_dat$Subject <- factor(test_dat$Subject)
subs <- unique(test_dat$Subject)

#subject charactaristics
setwd("~/PARC_study/behavioral_data/")
subchars <- read.csv("PARC_ScanTeam_Tracker.csv")
subchars$Subject <- factor(subchars$ID)
setdiff(subchars$Subject,unique(test_dat$Subject))
subchars <- subchars[!subchars$Subject==2782,]
subchars$Age <- subchars$Age.at.scan
subchars$Group <- subchars$Dx

## final test
setwd("~/Dropbox/PARC_Scan_behavioralfiles/final_test_data/")
finaltest_files <- dir(pattern="*correct.txt")
uberfinal <- read.delim(finaltest_files[1])
uberfinal$Subject <- finaltest_files[1]

for(ii in 2:length(finaltest_files)){
  sub_final_file <- read.delim(finaltest_files[ii])
  sub_final_file$Subject <- finaltest_files[ii]
  names(sub_final_file) <-names(uberfinal) #hack! names were entered differently by RA
  uberfinal <- rbind(uberfinal,sub_final_file)
}

uberfinal$Subject <- substring(uberfinal$Subject,4,7)
# uberfinal$trial <- uberfinal$index
uberfinal$Subject <- factor(uberfinal$Subject)
# View(uberfinal[!uberfinal$correct %in% c(1,0),])
uberfinal$final_trial <- uberfinal$trial

### 
to_merge_final <- uberfinal[,c('imgFile','correct','Subject','final_trial')]
names(to_merge_final)<- c('imgFile','finaltest_correct','Subject','final_trial')
to_merge_chars <- subchars[,c('Subject','Group','Sex','Age','Handedness')]
to_merge <- merge(to_merge_chars,to_merge_final)

bothtest <- merge(test_dat,to_merge)
study_finalcorrect <-  merge(studytdat,to_merge)

## reward variable is off
bothtest$reward <- substr(bothtest$condkey,2,2)
study_finalcorrect$reward <- substr(study_finalcorrect$condkey,2,2)

### reshuffle
study_finalcorrect <- study_finalcorrect[order(study_finalcorrect$index),]
study_finalcorrect <- study_finalcorrect[order(study_finalcorrect$Subject),]

bothtest <- bothtest[order(bothtest$index),]
bothtest <- bothtest[order(bothtest$Subject),]

rm(studytdat,finaltest_files,ii,sub_final_file,subchars,test_dat,to_merge,to_merge_chars,to_merge_final,uberfinal)


