library(dplyr)
library(stringr)
objects()

tests <- students

for (n in names(envir_list)){
	short <- (n
		%>% str_replace(".merge", "")
		%>% str_replace(".patch", "")
		%>% str_replace("$", ".test")
	)
	tests <- (left_join(tests,
		(envir_list[[n]]$scores
			%>% transmute(idnum=idnum, bestScore=bestScore)
			%>% setNames(c("idnum", short))
		)
	))
}

tests <- (tests 
	%>% mutate(final.test = ifelse(is.na(final.test), 0, final.test))
)

summary(tests)

# rdsave(tests)
