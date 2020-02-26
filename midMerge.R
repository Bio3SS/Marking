library(readr)
library(dplyr)

## Pull midterm number from target name
num <- gsub("[[:alpha:].]", "", rtargetname)

## Use right_join to drop students dropped from TAmarks
## Need to track students who didn't write, and confirm MSAF NAs
scores <- (scores 
	%>% right_join(sa
		%>% setNames(sub(num, "_curr", names(.)))
		%>% transmute(idnum=idnum,sa=sa_curr, taVer=taVer_curr)
	)
	%>% mutate(bubVer = ifelse(bubVer==-1, NA, bubVer)
		## , bubVer = ifelse(is.na(bubVer), taVer, bubVer)
	)
)
head(scores)
summary(scores)

## This code is cumbersome, but I'm trying to remember to use NAs 
## in a principled fashion

## Mismatches
print(filter(scores, (
	(!is.na(taVer)) & (taVer != bubVer)
	| (!is.na(bubVer) & (bestVer != bubVer))
	| (!is.na(verScore) & (verScore>0) & (verScore != bestScore))
)))

print(filter(scores, 
	is.na(bubVer) & !is.na(bestScore)
))

## Half tests?
print(filter(scores, is.na(bestScore)))
print(filter(scores, is.na(sa)))

scores <- (scores 
	%>% mutate(
		bestScore = ifelse((is.na(bestScore) & sa==0), 0, bestScore)
		, bestScore = bestScore+sa
	)
)

print(summary(scores))
