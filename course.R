library(shellpipes)
library(dplyr)
library(readr)

## 0 for no downgrade (power = number completed)
## 1000 for no balance (downgrade "dilutes" the power)
downgrade <- 0
offset <- 0.5 ## Add before truncating
testwt <- c(25, 25, 40)
asntot <- c(16, 13, 10)
rho <- 1.5

loadEnvironments()
course <- rdsRead()

course <- (course

	%>% mutate(NULL
		, polls = naZero(polls)
		, final = naZero(final)
	)
	%>% rowwise()
	%>% mutate(
		testAve = powerAve(
			scores=c(midterm1, midterm2, final)
			, dens=testwt, downgrade=downgrade
			, rho=rho
		)
	)

	%>% mutate(
		asnAve = powerAve(
			scores=c(A1, A2, A3)
			, dens=asntot, weights=1, downgrade=downgrade
		)
	)

	%>% mutate(
		courseGrade = 90*testAve + 10*asnAve + polls
		, courseGrade = floor(courseGrade+offset)
	)
)

summary(course)

grades <- (course
	%>% transmute(Username, idnum
		, polls=round(polls, 3)
		, testAve=round(testAve, 3)
		, asnAve=round(asnAve, 3)
		, courseGrade
	)
) 

csvSave(grades)

rdsSave(course)
