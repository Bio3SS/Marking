library(dplyr)
library(tidyr)
library(stringr)
library(shellpipes)

## scores <- rdsRead("marks")
## names(scores)
## quit()

scores <- (rdsRead("marks")
	%>% select(Username, idnum, A1, A2, A3, A4)
)

testscores <- rdsReadList("merge", trim = ".merge.*")

for(n in names(testscores)){
	t <- (testscores[[n]]
		%>% select(Username, !!n := total)
	)
	scores <- full_join(scores, t)
}

summary(scores)

print(scores %>% filter(midterm1==0 | midterm2==0))

rdsSave(scores)
