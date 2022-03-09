library(dplyr)

library(shellpipes)

marks <- tsvRead() %>% select(-c(Last,First))

summary(marks %>% mutate_if(is.character, as.factor))

quit()

## Check notes
print(marks %>% select(A1Note) %>% distinct )

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

## rdsSave(marks)
## quit()

## Check notes
print(marks %>% select(M1Note) %>% distinct )

quit()

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

## rdsSave(marks)
## quit
