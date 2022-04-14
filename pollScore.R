library(dplyr)
library(shellpipes)

loadEnvironments()

needMax <- 0.9
weight <- (sum(1/qq))
print(weight)

print(dim(as.matrix(report)))
print(length(qq))

score <- apply(as.matrix(report), 1, function(s){
	return(sum(
		(nchar(as.character(s))>1)/qq
		, na.rm=TRUE
	))
})

scoref <- data.frame(id=id, score=score)
(scoref
	%>% filter(grepl("UNKNOWN", id))
	%>% mutate(score=score/(needMax*weight))
) %>% csvSave

sf <- (scoref
	%>% mutate(id = sub(",.*", "", id))
	%>% group_by(id)
	%>% summarise(score = sum(score))
)
summary(sf)

ef <- tableRead()
summary(ef)

df <- full_join(sf, ef)
df <- within(df, {
	extra[is.na(extra)] <- 0
	score[is.na(score)] <- 0
	manual[is.na(manual)] <- 0
	score <- score+extra
	score <- 2*pmin(1, score/(needMax*weight)+manual/2)
	score <- round(100*score)/100
})

## What's up with manual
print(df %>% filter(manual>0))

## Check for suspicious overflows
print(df %>% filter(score>2))

scores <- (df
	%>% filter(!is.na(score))
	%>% transmute(Username=id, Polls_score=score)
)

summary(scores)

rdsSave(scores)
