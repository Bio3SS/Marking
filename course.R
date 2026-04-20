library(shellpipes)
library(dplyr)
library(readr)

## downgrade dilutes the power-balance effect
## 0 for no downgrade (power = number completed)
## 1000 for no balance (downgrade "dilutes" the power)
## rho is a test-curve multiplier (rho=1 for no test curve)
downgrade <- 0
offset <- 0.5 ## Add before truncating
testwt <- c(25, 25, 40)
asntot <- c(16, 13, 12) ## SEE ALSO A1 …  below
rho <- 1.4

loadEnvironments()
course <- rdsRead()

course <- (course
	%>% mutate(NULL
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
			scores=c(Assignment1, Assignment2, Assignment3)
			, dens=asntot, weights=1, downgrade=downgrade
		)
	)

	%>% mutate(
		courseGrade = 90*testAve + 10*asnAve
		, courseGrade = floor(courseGrade+offset)
	)
)

summary(course)

grades <- (course
	%>% transmute(Username, idnum
		, testAve=round(testAve, 3)
		, asnAve=round(asnAve, 3)
		, courseGrade
	)
) 

csvSave(grades)

rdsSave(course)
