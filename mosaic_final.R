library(dplyr)
library(readr)
library(shellpipes)

Class <- 2092 ## 2024 Apr 23 (Tue)

course <- (rdsRead()
	%>% transmute(NULL
		, Class=Class
		, ID = sub("#", "", idnum)
		, mark=courseGrade
	)
)

csvSave(course, col_names=FALSE)
