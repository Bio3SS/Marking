library(dplyr)

aname <- gsub("[.].*", "", rtargetname)
ascore <- paste0(aname , "_score")

scores <- (assign
	%>% select(idnum, !!aname)
	%>% rename(!!ascore := !!aname)
)

summary(scores)
