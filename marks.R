library(dplyr)

library(shellpipes)

marks <- tsvRead() %>% select(-c(Last,First))

summary(marks %>% mutate_if(is.character, as.factor))

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

summary(marks %>% mutate_if(is.character, as.factor))
rdsSave(marks)
