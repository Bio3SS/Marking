library(dplyr)
library(readr)
library(shellpipes)

loadEnvironments()

scores <- rdsRead()

summary(scores)

ss <- (scores
	%>% transmute(
		OrgDefinedId=idnum , Username=macid
		, `Course Points Grade` = courseGrade
		, `End-of-Line Indicator` = "#"
	)
)
csvSave(ss)
