library(dplyr)

library(shellpipes)

## A fairly horrible hybrid because it's been used differently for midterm marks and final marks.

## 2024: classlist has accumulated a bunch of uploaded stuff, so select what you want
class <- (csvRead()
	%>% mutate(Username=sub("#", "", Username))
	%>% select(OrgDefinedId, Username)
)

## 2022: Instead of trying to control the spreadsheet, I made a master sheet on top of Celine's various sheets
marks <- (tsvRead() %>% select(-c(Last,First))
	%>% right_join(class)
	%>% rename(idnum = OrgDefinedId)
)

summary(marks %>% mutate_if(is.character, as.factor))

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
