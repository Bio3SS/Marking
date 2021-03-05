library(dplyr)
library(shellpipes)

scores <- rdsRead()

summary(scores)

aname <- gsub("[.].*", "", targetname())
ascore <- paste0(aname , "_score")

scores <- (scores
	%>% select(macid, score)
	%>% rename(!!ascore := score)
)

summary(scores)

rdsSave(scores)
