library(dplyr)

library(shellpipes)

scores <- (rdsRead()
	%>% transmute(Username, exam_score=total)
)

summary(scores)
rdsSave(scores)
