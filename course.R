
## 0 for no downgrade (power = number completed)
## 1000 for no balance
downgrade <- 0
examRho <- 1.3 ## odds curve for final
offset <- 0.999 ## 0 to round down
testwt <- c(25, 25, 40)
asntot <- c(16, 12, 10)

## it would be nice to get these back... why could Marvin upload negatives?
## avenueMissing <- -95
## avenueMSAF <- -99

library(dplyr)
library(readr)

## Put stuff together
## Don't treat missing final as NA
course <- (students
	%>% full_join(tests)
	%>% full_join(assign)
	%>% full_join(scores) ## Poll scores come directly so use this name
	%>% mutate(final.test = ifelse(is.na(final.test), 0, final.test))
	%>% mutate(final.test = oddsCurve(final.test, rho=examRho, points=40))
)

course <- (course
	%>% rowwise()
	%>% mutate(
		testAve = powerAve(
			scores=c(midterm1.test, midterm2.test, final.test)
			, dens=testwt, weights=testwt, downgrade=downgrade
		)
	)

	%>% mutate(asnAve = powerAve(
		scores=c(assign1, assign2, assign3)
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

(course
	%>% transmute(macid, idnum
		, Polls_score=round(Polls_score, 3)
		, testAve=round(testAve, 3)
		, asnAve=round(asnAve, 3)
		, courseGrade=round(courseGrade, 3)
	)
) %>% write_csv(csvname)

# rdsave(course)
