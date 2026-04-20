library(dplyr)
library(stringr)

library(shellpipes)

class <- (csvRead()
	|> mutate(Username=sub("#", "", Username))
	|> rename_with(~ sub(" ", "", .x))
	|> rename_with(~ sub(" .*", "", .x))
)

names(class)
class <- (class
	|> mutate(across(matches("^Assignment"), ~ if_else(is.na(.x), 0, .x)))
)

## summary(class)
## quit()

marks <- (tsvRead() 
	|> right_join(class)
	|> mutate(idnum = as.character(idnum))
	|> mutate(OrgDefinedId=sub("#", "", OrgDefinedId))
)

stopifnot(identical(marks$idnum, marks$OrgDefinedId))
marks <- marks |> select(-c(OrgDefinedId, `End-of-LineIndicator`))

apairs <- tibble(
	assignment = names(marks) |> str_subset("^Assignment")
	, notes = str_replace(assignment, "Assignment", "A") |> str_c("Notes")
)

for (i in seq_len(nrow(apairs))) {
	marks <- (marks
		|> mutate(
			across(
				all_of(apairs$assignment[i])
				, ~ if_else(is.na(marks[[apairs$notes[i]]]), NA, .x)
			)
		)
	)
}
marks <- marks |> select(-apairs$notes)

summary(marks %>% mutate_if(is.character, as.factor))
rdsSave(marks)

