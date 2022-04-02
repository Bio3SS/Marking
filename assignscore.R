library(dplyr)
library(shellpipes)

marks <- rdsRead()


aname <- paste0("A", pipeStar())
ascore <- paste0(aname , "_score")
summary(marks)

print(aname)
print(ascore)

scores <- (marks
	%>% select(Username, !!aname)
	%>% rename(!!ascore := !!aname)
)

summary(scores)

rdsSave(scores)
