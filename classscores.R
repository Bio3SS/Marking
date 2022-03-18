library(dplyr)
library(shellpipes)

class <- (csvRead()
	%>% mutate(Username=sub("#", "", Username))
	%>% select(-c("End-of-Line Indicator"))
)

scores <- rdsRead()

## summary(class %>% mutate_if(is.character, as.factor))
## summary(scores %>% mutate_if(is.character, as.factor))

scores <- (scores
	%>% left_join(class, by=c("idnum" = "OrgDefinedId"))
)

print(scores %>% filter(is.na(Username)))

## summary(scores %>% mutate_if(is.character, as.factor))
rdsSave(scores)
