library(dplyr)
library(readr)
library(shellpipes)

loadEnvironments()

scores <- rdsRead()

summary(scores)

ss <- (scores
	%>% transmute(
		OrgDefinedId=idnum , Username
		, `Course Points Grade` = courseGrade
		, `End-of-Line Indicator` = "#"
	)
)
csvSave(ss)
