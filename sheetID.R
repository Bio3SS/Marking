library(readr)
library(dplyr)
library(shellpipes)

currids <- (csvRead()
	%>% transmute(macid = sub("#", "", Username))
)

sheet <- (currids
	%>% left_join(tsvRead())
	%>% mutate(idnum=as.character(idnum))
)

names(sheet)

students <- sheet %>% select(idnum, macid)
head(students)
dim(students)

saveVars(students, sheet)
