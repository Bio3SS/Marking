library(readr)
library(dplyr)

## Pull midterm number from target name
num <- gsub("[[:alpha:].]", "", rtargetname)

## Use right_join to drop students dropped from TAmarks
## Need to track students who didn't write, and confirm MSAF NAs
scores <- (scores 
	%>% right_join(sa
		%>% setNames(sub(num, "_curr", names(.)))
		%>% transmute(idnum=idnum,sa=sa_curr, manVer=manVer_curr)
	)
	%>% mutate(version = ifelse(version==-1, NA, version)
		, version = ifelse(is.na(version), manVer, version)
	)
)
head(scores)
summary(scores)

## This code is cumbersome, but I'm trying to remember to use NAs 
## in a principled fashion

## Need to check bestVer again, because we've supplemented
mismatch <- filter(scores, (
	(!is.na(manVer)) & (manVer != version)
	| (!is.na(version) & (bestVer != version))
	| (!is.na(verScore) & (verScore>0) & (verScore != bestScore))
))
print(mismatch)
## stopifnot(nrow(mismatch)==0)

print(filter(scores, is.na(bestScore)))
print(filter(scores, is.na(sa)))
print(filter(scores, version<0))

scores <- (scores 
	%>% mutate(
		bestScore = ifelse((is.na(bestScore) & sa==0), 0, bestScore)
		, bestScore = bestScore+sa
	)
)

print(summary(scores))
