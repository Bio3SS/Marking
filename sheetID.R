
library(readr)
library(dplyr)

sheet <- (read_tsv(input_files[[1]])
	%>% anti_join(
		read_csv(input_files[[2]])
		%>% mutate(idnum=as.character(idnum))
	)
)

names(sheet)

students <- sheet %>% select(idnum, macid)

