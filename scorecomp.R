library(readr)
library(dplyr)

library(shellpipes)

scores <- rdsRead()

scans <- (
	csvRead( , col_names = c("macid", "idnum", "score"))
	%>% mutate(
		macid=sub("@.*", "", macid)
		, idnum = paste0("#",idnum)
	)
)

scores <- full_join(
	scans, scores
)

## For scantron-key problems
print(scores %>% filter(verScore != bestScore))
print(scores %>% filter(score!=verScore | verScore != bestScore))

rdsSave(scores)
