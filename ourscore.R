library(dplyr)

library(shellpipes)

responses <- tsvRead(col_names=FALSE)
print (responses%>% mutate_if(is.character, as.factor) %>% summary)

key <- csvRead()
summary(key)

answers <- as.matrix(responses[-(1:2)])
answers <- matrix(match(answers, LETTERS), nrow=nrow(answers))
dim(answers)
summary(answers)
