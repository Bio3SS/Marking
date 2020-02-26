library(dplyr)

## target parsing not implemented yet because transmute syntax
testname <- paste0(
	gsub("[.].*", "", rtargetname)
	, "_score"
)
print(testname)

scores <- (scores
	%>% transmute(idnum, bestScore)
	%>% rename(!!testname := bestScore)
)

summary(scores)
