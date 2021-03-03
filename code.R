library(shellpipes)
library(dplyr)

code <- (csvRead(pat="code", col_names=FALSE)
	%>% transmute(Username=X1, honor=TRUE)
) 

scores <- (full_join(code , csvRead(pat="scores"))
	%>% select(Username, honor, Score)
)

print(scores %>% filter(is.na(Score)))

scores <- (scores
	%>% transmute()
)

saveVars(scores)
