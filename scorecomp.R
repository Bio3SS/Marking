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

print(scores %>% filter(bubVer!=bestVer))
print(scores %>% filter(score!=bestScore))

rdsSave(scores)
