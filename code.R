library(shellpipes)
library(dplyr)

code <- (csvRead(pat="code", col_names=FALSE)
	%>% transmute(Username=X1, honor=TRUE)
) 

scores <- (full_join(code , csvRead(pat="scores"))
	%>% select(Username, honor, Score)
)

cat("No test")
print(scores %>% filter(is.na(Score)))
scores <- scores %>% filter(!is.na(Score))

scores <- (scores
	%>% transmute(macid=Username
		, score=ifelse(is.na(honor), NA, Score)
	)
)

cat("No pledge")
print(scores %>% filter(is.na(score)))

saveVars(scores)
