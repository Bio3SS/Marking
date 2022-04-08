## Deprecated 2022 Apr 07 (Thu)
library(dplyr)
library(readr)
library(shellpipes)

scores <- rdsRead()

summary(scores)

ss <- (left_join(students, scores)
	## %>% mutate(idnum=(sub("#", "", idnum)))
	%>% setNames(gsub(pattern="_score", replacement=" Points Grade" , names(.)))
	%>% mutate(`End-of-Line Indicator` = "#")
	%>% rename(OrgDefinedId=idnum , Username=macid)
)
summary(ss)
csvSave(ss)
