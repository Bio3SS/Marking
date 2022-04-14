library(shellpipes)

loadEnvironments()

dim(rec)
dim(report)

names(id) <- make.names(names(id))
print(names(id))

print(names(report))

## Transfer the fake question from question world to id world
fq <-(which(grepl("macid", names(report))))
if(length(fq)==1){
	id$ques <- tolower(report[[fq]])
	report <- report[-fq]
	fqgroup <- fq:(fq+2)
	# rec <- rec[-fqgroup]
	rec <- rec[-fq]
} else {id$ques <- "UNKNOWN"}

dim(rec)
dim(report)

## What does the id frame look like?
## print(summary(id))

emails <- with(id, {sapply(1:nrow(id), function(i){
	if(grepl("mcmaster", Email[[i]], ignore.case=TRUE)){
		return(as.character(Email[[i]]))
	}
	if(grepl("mcmaster", Custom.report.ID[[i]], ignore.case=TRUE)){
		return(as.character(Custom.report.ID[[i]]))
	}
	if(grepl("\\w", ques[[i]])){
		return(as.character(ques[[i]]))
	}
	return(paste(
		"UNKNOWN"
		, First.name[[i]]
		, Last.name[[i]]
		, Email[[i]]
		, Custom.report.ID[[i]]
		, Screen.name[[i]]
		, Participant.ID[[i]]
		, sep="_"
	))
})})
id <- sub("@m.*", "", emails, ignore.case=TRUE)

print(id)

print(class(rec))
print(rec)

## Get rid of time info, but keep date info (poll Everywhere has not been reliable about syntax)
rec <- as.data.frame(sapply(rec, function(r){
	return(sub(" +.*", "", r))
}))
print(rec)

## Pull dates from the poll matrix (there will be blanks as well as repeats)
qdates <- sapply(rec, function(r){
	return(min(r[!is.na(r) & r!=""]))
})

qdates <- unlist(qdates)
print(qdates)

## Number of polls on each date
qq <- sapply(qdates, function(q){
	return(sum(q==qdates))
})

## Look at the answers
summary(qdates)
summary(qq)

data.frame(qdates, qq)

dim(report)
class(qq)
length(qq)

saveVars(id, report, qq)
