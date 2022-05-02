library(dplyr)
library(readr)
library(shellpipes)

Class <- 2327 ## 2022 May 02 (Mon

course <- (rdsRead()
	%>% transmute(NULL
		, Class=Class
		, ID = sub("#", "", idnum)
		, mark=courseGrade
	)
)

csvSave(course, col_names=FALSE)
