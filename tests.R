library(dplyr)
library(tidyr)
library(stringr)
library(shellpipes)

tests <- (rdsRead("marks")
	%>% select(Username, idnum, A1, A2, A3)
)

testscores <- rdsReadList("merge", trim = ".merge.*")

for(n in names(testscores)){
	t <- (testscores[[n]]
		%>% select(Username, !!n := total)
	)
	tests <- full_join(tests, t)
}

tests <- (tests
	%>% mutate(
		final= ifelse(is.na(final), 0, final)
	)
)

summary(tests)

print(tests %>% filter(midterm1==0 | midterm2==0))

rdsSave(tests)
