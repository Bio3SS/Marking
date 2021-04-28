library(readr)
library(dplyr)
library(shellpipes)

loadEnvironments()

names(sheet)
names(students)

## Name	macid	idnum	Assignment 1	Assignment 2	Midterm 1 Mark	Midterm 1 Version	Assignment 3	Midterm 2 Mark	Midterm 2 Version	Assignment 4
## Dropped some Avenue-ish stuff. Can be found in avenueMerge, and maybe in the old (Tests/) version of this file
## Don't comment things out; it will bite you. Add blank column heads should work?

tests <- (sheet 
	%>% transmute(idnum=idnum, macid=macid
		, midterm1=`Midterm 1`
		, midterm2=`Midterm 2`
	)
)

summary(tests)

## This seems horrible (causes errors when I forget to switch)
## Figure out how to do it fancy
assigns <- (sheet 
	%>% transmute(idnum=idnum, macid=macid
		, assign1=`Assignment 1`
		, assign2=`Assignment 2`
		, assign3=`Assignment 3`
		, assign4=`Assignment 4`
	)
)

saveVars(tests, assigns)
