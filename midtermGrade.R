library(dplyr)

library(shellpipes)

scores <- (rdsRead()
	%>% transmute(Username, SA_score=SA, MC_score=MC)
	%>% setNames(sub("(.*_score)", paste0("M", pipeStar(), "\\1"), names(.)))
)

summary(scores)
rdsSave(scores)
