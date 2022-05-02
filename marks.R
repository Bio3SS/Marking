library(dplyr)

library(shellpipes)

class <- (csvRead()
	%>% mutate(Username=sub("#", "", Username))
	%>% select(-c("End-of-Line Indicator"))
)

## Instead of trying to control the spreadsheet, this year I made a master sheet on top of Celine's various sheets
marks <- (tsvRead() %>% select(-c(Last,First))
	%>% right_join(class)
	%>% rename(idnum = OrgDefinedId)
)

## summary(marks %>% mutate_if(is.character, as.factor))

## Make this into a loop

if ("A1Total" %in% names(marks)){

	## Look for MSAF with mark
	stopifnot(
		nrow(
			marks %>% filter(A1Note=="MSAF" & !is.na(A1Total) & A1Total>0)
		) == 0
	)

	marks <- (marks %>%
		mutate(NULL
			, A1=A1Total
			, A1=ifelse(A1Note=="MSAF", NA, A1)
			, A1=ifelse(A1Note=="LATE", 0.9*A1, A1)
		) %>% select(-c(A1Note,A1Total))
	)
}

if ("A2Total" %in% names(marks)){

	## Look for MSAF with mark
	stopifnot(
		nrow(
			marks %>% filter(A2Note=="MSAF" & !is.na(A2Total) & A2Total>0)
		) == 0
	)

	marks <- (marks %>%
		mutate(NULL
			, A2=A2Total
			, A2=ifelse(A2Note=="MSAF", NA, A2)
			, A2=ifelse(A2Note=="LATE", 0.9*A2, A2)
		) %>% select(-c(A2Note,A2Total))
	)
}

if ("A3Total" %in% names(marks)){

	## Look for MSAF with mark
	stopifnot(
		nrow(
			marks %>% filter(A3Note=="MSAF" & !is.na(A3Total) & A3Total>0)
		) == 0
	)

	marks <- (marks %>%
		mutate(NULL
			, A3=A3Total
			, A3=ifelse(A3Note=="MSAF", NA, A3)
			, A3=ifelse(A3Note=="LATE", 0.9*A3, A3)
		) %>% select(-c(A3Note,A3Total))
	)
}

## Right now the two midterms are different (only one with SA)
## Is it worth looping? If so, we should be checking for Note, not SA
if ("M1SA" %in% names(marks))
{
	## Look for MSAF with mark
	stopifnot(
		nrow(
			marks %>% filter(M1Note=="MSAF" & !is.na(M1SA) & M1SA>0)
		) == 0
	)

	marks <- (marks %>%
		mutate(NULL
			, M1SA=ifelse(M1Note=="MSAF", NA, M1SA)
		) %>% select(-c(M1Note))
	)
}

if ("M2Note" %in% names(marks))
{
	marks <- (marks %>%
		mutate(NULL
			, M2SA=ifelse(M2Note=="MSAF", NA, 0)
			, M2Ver=NA
		)
	)
}

summary(marks %>% mutate_if(is.character, as.factor))
rdsSave(marks)
