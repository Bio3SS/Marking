## Copied from midMerge 2022 May 01 (Sun)

library(dplyr)

library(shellpipes)

marks <- rdsRead("marks")
scores <- rdsRead("score")

names(scores)
names(marks)

scores <- (marks
	%>% left_join(scores, by = "idnum")
	%>% select(Username, idnum, bubVer, bestVer, bestScore)
)

scores <- (scores 
	%>% rename(total=bestScore)
	%>% select(
		Username, total
	)
)

print(tsvRead())

scores <- (scores
	|> left_join(tsvRead())
	|> transmute(Username=Username
		, total = ifelse(!is.na(defMark), defMark, total)
	)
)

print(scores %>% filter(is.na(total)))

summary(scores)

rdsSave(scores)

