library(readr)
library(dplyr)

scans <- (
	read_csv(input_files[[1]]
		, col_names = c("macid", "idnum", "score")
	)
	%>% mutate(
		macid=sub("@.*", "", macid)
		, idnum = paste0("#",idnum)
	)
)

scores <- full_join(
	scans, scores
)

## This is pointless when the office doesn't score for us
print(scores %>% filter(bubVer!=bestVer))

## This is pointless when the office doesn't score for us
print(scores %>% filter(score!=bestScore))

# rdsave(scores)
