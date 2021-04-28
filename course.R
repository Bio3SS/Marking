library(shellpipes)
library(dplyr)
library(readr)

## 0 for no downgrade (power = number completed)
## 1000 for no balance (downgrade "dilutes" the power)
downgrade <- 0
examRho <- 1.3 ## odds curve for final
offset <- 0.5 ## 0 to round down
testwt <- c(25, 25, 40)
asntot <- c(16, 10, 14, 10)

loadEnvironments()
tests <- rdsRead("test")
polls <- rdsRead("poll")

summary(tests)
summary(assigns)
summary(polls)

## Put stuff together
course <- (tests
	%>% left_join(assigns)
	%>% left_join(polls)
)

print(course, n=1e7)

course <- (course
	%>% rowwise()
	%>% mutate(
		testAve = powerAve(
			scores=c(midterm1, midterm2, final)
			, dens=testwt, weights=testwt, downgrade=downgrade
		)
	)

	%>% mutate(asnAve = powerAve(
		scores=c(assign1, assign2, assign3, assign4)
		, dens=asntot, weights=1, downgrade=downgrade
	))

	%>% mutate(
		Polls_score = naZero(Polls_score)
	)

	%>% mutate(
		courseGrade = 90*testAve + 10*asnAve + Polls_score
		, courseGrade = floor(courseGrade+offset)
	)
)

summary(course)

grades <- (course
	%>% transmute(macid, idnum
		, Polls_score=round(Polls_score, 3)
		, testAve=round(testAve, 3)
		, asnAve=round(asnAve, 3)
		, courseGrade
	)
) 

csvSave(grades)

rdsSave(course)
