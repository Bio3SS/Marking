library(readr)
library(dplyr)

sheet <- (read_tsv(input_files[[1]])
	%>% anti_join(
		read_csv(input_files[[2]])
		%>% mutate(idnum=as.character(idnum))
	)
)

## Name	macid	idnum	Assignment 1	Assignment 2	Midterm 1 Mark	Midterm 1 Version	Assignment 3	Midterm 2 Mark	Midterm 2 Version	Assignment 4
## Dropped some Avenue-ish stuff. Can be found in avenueMerge, and maybe in the old (Tests/) version of this file

sa <- (sheet 
	%>% transmute(idnum=idnum, macid=macid
		, sa1=`Midterm 1 Mark`, manVer1 = `Midterm 1 Version`
		## , sa2=`Midterm 2 Mark`, manVer2 = `Midterm 2 Version`
	)
)

summary(sa)

assign <- (sheet %>% 
	transmute(idnum, macid
		, attendance = (
			select(sheet, contains("Tutorial ")) %>% rowMeans(na.rm=TRUE)
		)
	) %>% bind_cols(
		select(sheet, contains("Assignment "))
		%>% setNames(make.names(names(.)))
	)
)
summary(assign)

students <- assign %>% select(idnum, macid)

# rdsave(sa, assign, students)

