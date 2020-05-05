library(dplyr)

## target parsing not implemented yet because transmute syntax
scores <- (course
	%>% transmute(idnum, courseFinal_score=courseGrade)
)

# rdsave(scores)
