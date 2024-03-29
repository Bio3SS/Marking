## completely remodeling 2022 Mar 17 (Thu)
## Also dropped some "patch" code for students who bubble their idno wrong
## see content.mk

library(dplyr)

library(shellpipes)

## Pull midterm number from target name

test <- paste0("M", pipeStar())

marks <- rdsRead("marks")
scores <- rdsRead("score")

names(scores)
names(marks)
summary(marks)

scores <- (marks
	%>% left_join(scores, by = "idnum")
	%>% setNames(sub(test, "", names(.)))
	%>% select(Username, idnum, SA, Ver, bubVer, bestVer, verScore, bestScore)
)

## Version problems
print(scores 
	%>% filter(!is.na(Ver) & ((Ver!=bubVer) | (verScore != bestScore)))
)

## Half tests?
print(filter(scores, is.na(SA) & !is.na(bestScore)))
print(filter(scores, !is.na(SA) & is.na(bestScore)))

scores <- (scores 
	%>% rename(MC=verScore)
	%>% mutate(NULL
		, total = ifelse((is.na(MC) & SA==0), 0, MC+SA)
	) %>% select(
		Username, SA, MC, total
	) %>% filter(!is.na(total))
)

summary(scores)

rdsSave(scores)

