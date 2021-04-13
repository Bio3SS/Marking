library(dplyr)
library(shellpipes)

loadEnvironments()
objects()

scores <- (full_join(scores, tests))
print(scores %>% filter(is.na(score)))
summary(scores)

scores <- scores %>% select(macid, score)

rdsSave(scores)
