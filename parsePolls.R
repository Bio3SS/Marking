
print(names(id))
## Does not work with current code, but was a good idea
## The fancy way would be to grep and rename id variables
firstname <- "First.name" 
lastname <- "Last.name"           
email <- "Email"                  

## Transfer the fake question from question world to id world

fq <-(which(grepl("macid", names(report))))
if(length(fq)==1){
	id$ques <- tolower(report[[fq]])
	report <- report[-fq]
	fqgroup <- fq:(fq+2)
	# rec <- rec[-fqgroup]
	rec <- rec[-fq]
} else {id$ques <- "UNKNOWN"}


## What does the id frame look like?
## print(summary(id))
## quit()

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

qdates <- sapply(rec, function(r){
	return(levels(r)[[2]])
})

qq <- sapply(qdates, function(q){
	return(sum(q==qdates))
})

data.frame(
	qdates, qq
)

# rdsave(id, report, qq)
