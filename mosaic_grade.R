library(dplyr)
library(readr)

Class <- 10646

roster <- read_csv(input_files[[1]])
names(roster) <- gsub(" ", "_", names(roster))

summary(course)
course <- (course
	%>% mutate(idnum = gsub("#", "", idnum)
		, courseGrade=courseGrade
	)
)

summary(course)

summary(roster)

## This mutate seems bad; if we could read the csv as strings in the first place it would be better.
## Check strings as factors if you do that
roster <- (roster
	%>% mutate(idnum=sprintf("%09d", as.numeric(ID))) 
	%>% left_join(course)
	%>% filter(final.test > 0)
	%>% transmute(Class=Class, idnum, mark=courseGrade)
) %>% write_csv(csvname, col_names=FALSE)

summary(roster)

print(dropCandidates <- roster %>% filter(is.na(mark)))

(roster
	%>% filter(!is.na(mark))
) %>% write_csv(csvname, col_names=FALSE)
