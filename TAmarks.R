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
## Don't comment things out; it will bite you. Add blank column heads should work?

sa <- (sheet 
	%>% transmute(idnum=idnum, macid=macid
		, sa1=`Midterm 1 Mark`, taVer1 = `Midterm 1 Version`
		, sa2=`Midterm 2 Mark`, taVer2 = `Midterm 2 Version`
	)
)

summary(sa)

assign <- (sheet %>% 
	transmute(idnum, macid)
	%>% bind_cols(
		select(sheet, contains("Assignment "))
		%>% setNames(make.names(names(.)))
	)
)
summary(assign)

## This seems horrible (causes errors when I forget to switch)
## Figure out how to do it fancy
assign <- (sheet 
	%>% transmute(idnum=idnum, macid=macid
		, assign1=`Assignment 1`, assign2=`Assignment 2`
		, assign3=`Assignment 3`
		## , assign4=`Assignment 4`
	)
)

students <- assign %>% select(idnum, macid)

# rdsave(sa, assign, students)

