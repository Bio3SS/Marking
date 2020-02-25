library(readr)
library(dplyr)

scans <- (
	read_csv(input_files[[1]]
		, col_names = c("email", "idnum", "score")
	)
	%>% mutate(email=sub("@.*", "", email))
	%>% rename(macid=email)
)

scores <- full_join(
	scans, scores
)

print(scores %>% filter(score!=bestScore))

# rdsave(scores)
