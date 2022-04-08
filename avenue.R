library(dplyr)
library(shellpipes)

scores <- rdsRead()

summary(scores)

## Use "across" to eliminate columns with no information?

is_pos <- function(v){
	v <- v[!is.na(v)]
	m <- max(v)
	return(m>0)
}

scores <- (scores
	%>% select_if(is_pos)
	%>% setNames(gsub(pattern="_score", replacement=" Points Grade" , names(.)))
	%>% mutate(`End-of-Line Indicator` = "#")
)
summary(scores)
csvSave(scores)
