library(dplyr)
library(readr)
library(shellpipes)

Class <- 7901 ## 2026 Apr 19 (Sun)

course <- (rdsRead()
	%>% transmute(NULL
		, Class=Class
		, ID = sub("#", "", idnum)
		, mark=courseGrade
	)
)

csvSave(course, col_names=FALSE)
