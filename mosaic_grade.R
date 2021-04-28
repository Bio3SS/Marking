library(dplyr)
library(readr)
library(shellpipes)

Class <- 8297 ## 2021 Apr 28 (Wed)

roster <- csvRead()
names(roster) <- gsub(" ", "_", names(roster))
print(roster$Email)

course <- rdsRead()
summary(course)

roster <- (roster
	%>% mutate(macid = sub("@.*", "", Email))
	%>% left_join(course)
)

summary(roster)

print(roster %>% filter(is.na(courseGrade)))

roster <- (roster
	%>% transmute(Class=Class, idnum, mark=courseGrade)
)

csvSave(roster)
