
### instead run!
source("~/PARC_study/Jim_scripts/pipeline/read_behavioral_files.R") #read in behavioral files



# str(test_dat)
# str(uberfinal)
xtabs(~Rate.resp+Subject,bothtest)
 xtabs(~finaltest_correct+Subject,bothtest)
xtabs(~Subject+finaltest_correct,bothtest)
xtabs(finaltest_correct~Subject+reward,bothtest)
xtabs(~finaltest_correct+reward,bothtest)
xtabs(~finaltest_correct+reward+Group,bothtest)

xtabs(~finaltest_correct+Group,bothtest)
summary(xtabs(~finaltest_correct+Group,bothtest))
addmargins(xtabs(~finaltest_correct+reward+Group,bothtest))

addmargins(xtabs(~finaltest_correct+reward+Group,bothtest[!bothtest$Subject %in% to_exclude_behavior,]))

xtabs(~Rate.resp+Group,bothtest)
summary(xtabs(~Rate.resp+Group,bothtest)) # no bias in ratings used
addmargins(xtabs(~finaltest_correct+Rate.resp+Group,bothtest))



xtabs(~finaltest_correct+Rate.resp,bothtest)
xtabs(~finaltest_correct+Subject,bothtest)
addmargins(xtabs(~finaltest_correct+Rate.resp+Subject,bothtest))





### fix the goddamn ?s

bothtest[!bothtest$finaltest_correct %in% c(0,1),c('Subject','final_trial','finaltest_correct')]


#### 
bothtest
xtabs(~finaltest_correct+Group,bothtest[bothtest$Rate.resp==6,])
summary(xtabs(~finaltest_correct+Group,bothtest[bothtest$Rate.resp==6,]))

