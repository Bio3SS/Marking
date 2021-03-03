
library(readr)
library(dplyr)
library(shellpipes)

sheet <- (tsvRead()
	%>% anti_join(
		csvRead()
		%>% mutate(idnum=as.character(idnum))
	)
)

names(sheet)

students <- sheet %>% select(idnum, macid)

saveVars(students, sheet)
