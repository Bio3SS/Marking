library(dplyr)

students <- (students
	%>% mutate (idstring = as.character(idnum))
)

summary(students)
summary(scores)

new <- (
	inner_join(students, scores, by = c("idstring" = "macid"))
	%>% select(macid, Polls_score)
) 

scores <- (scores
	%>% bind_rows(new)
	%>% group_by(macid)
	%>% summarise(Polls_score=sum(Polls_score))
	%>% right_join(students)
	%>% select(macid, Polls_score)
)

summary(scores)

# rdsave (scores)
