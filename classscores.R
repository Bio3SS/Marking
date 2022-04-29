library(dplyr)
library(shellpipes)

scores <- rdsRead()

## summary(class %>% mutate_if(is.character, as.factor))
## summary(scores %>% mutate_if(is.character, as.factor))

scores <- (scores
	%>% full_join(class, by=c("idnum" = "OrgDefinedId"))
)

summary(scores %>% mutate_if(is.character, as.factor))
print(scores %>% filter(is.na(Username)))
print(scores %>% filter(is.na(bestScore)))

rdsSave(scores)
