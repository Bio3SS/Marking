library(dplyr)

library(shellpipes)

## A fairly horrible hybrid because it's been used differently for midterm marks and final marks.

## 2024: classlist has accumulated a bunch of uploaded stuff, so select what you want
class <- (csvRead()
	%>% select(Username)
	%>% mutate(Username=sub("#", "", Username))
)

## 2026: Trying again to control the spreadsheet
## 2022: Instead of trying to control the spreadsheet, I made a master sheet on top of Celine's various sheets
marks <- (tsvRead() 
	|> right_join(class)
	|> mutate(idnum = as.character(idnum))
)

summary(marks %>% mutate_if(is.character, as.factor))
rdsSave(marks)

quit()

## Maybe this stuff comes in later? 2026 Mar 10 (Tue)
scores <- marks |> select(Username, idnum, M1Ver, M2Ver)

for (col in names(marks)){
	tag <- sub("SA", "SATotal", col)
	if(grepl("Total$", tag)){
		base <- sub("Total$", "", tag)
		note <- sub("Total$", "Note", tag)
		note <- sub("SANote$", "Note", note)

		v <- marks[[col]]
		n <- marks[[note]]
		stopifnot(sum(!is.na(n) & n=="MSAF" & !is.na(v) & v!=0)==0)
		v <- ifelse(!is.na(n) & n=="MSAF", NA, v)
		v <- ifelse(!is.na(n) & n=="LATE", 0.9*v, v)
		scores[[base]] <- v
	}
}

## summary(marks %>% mutate_if(is.character, as.factor))
summary(scores %>% mutate_if(is.character, as.factor))
rdsSave(scores)
