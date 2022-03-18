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

scores <- (marks
	%>% left_join(scores, by = c("Username"="macid"))
	%>% setNames(sub(test, "", names(.)))
	%>% select(Username, idnum, SA, Ver, bubVer, bestVer, bestScore)
)

## Version problems
print(scores 
	%>% filter(!is.na(Ver) & (Ver!=bubVer) | (Ver != bestVer))
)

## Half tests?
print(filter(scores, is.na(SA) & !is.na(bestScore)))
print(filter(scores, !is.na(SA) & is.na(bestScore)))

quit()

scores <- (scores 
	%>% mutate(
		bestScore = ifelse((is.na(bestScore) & sa==0), 0, bestScore)
		, bestScore = bestScore+sa
	)
)

print(summary(scores))
