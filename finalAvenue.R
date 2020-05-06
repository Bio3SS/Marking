library(readr)
library(dplyr)

scores <- (read_csv(input_files[[1]]
	, comment = "#"
)
	%>% transmute(
		idnum = paste0("#", sprintf("%08d", `Org Defined ID`))
		, bestScore =  Score
	)
) 

summary(scores)
