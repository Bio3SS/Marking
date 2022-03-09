library(dplyr)
library(shellpipes)

scores <- rdsRead()

summary(scores)

scores <- (scores
	%>% setNames(gsub(pattern="_score", replacement=" Points Grade" , names(.)))
	%>% mutate(`End-of-Line Indicator` = "#")
)
summary(scores)
csvSave(scores)
