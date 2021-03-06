library(dplyr)
library(shellpipes)

loadEnvironments()

aname <- gsub("[.].*", "", targetname())
ascore <- paste0(aname , "_score")

summary(assign)

quit()

scores <- (assign
	%>% select(idnum, !!aname)
	%>% rename(!!ascore := !!aname)
)

summary(scores)
