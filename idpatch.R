library(readr)
library(dplyr)

corTab <- read_csv(input_files[[1]]
	, col_names <- c("idnum", "patch_idnum")
)

scores <- (scores
	%>% left_join(corTab)
	%>% mutate(idnum=ifelse(is.na(patch_idnum)
		, idnum, as.character(patch_idnum))
	)
	%>% select(-patch_idnum)
)

summary(scores)

# rdsave(scores)
