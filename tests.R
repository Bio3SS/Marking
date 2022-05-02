library(dplyr)
library(tidyr)
library(stringr)
library(shellpipes)

testscores <- rdsReadList()

summary(testscores)

quit()

summary(tests)

## Add MSAF NAs for midterms; eliminate all NAs for final
tests <- (left_join(tests, testscores)
	%>% transmute(
		macid, idnum
		, midterm1 = ifelse(is.na(midterm1), NA, midterm1.merge)
		, midterm2 = ifelse(is.na(midterm2), NA, midterm2.merge)
		, final= ifelse(is.na(final.merge), 0, final.merge)
	)
)

summary(tests)

rdsSave(tests)
