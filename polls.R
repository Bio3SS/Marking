## Go through this step by step and figure out what PollEverywhere has changed ☹
report <- read.csv(input_files[[1]])
print(names(report))

rectext = "Received.at"
modtext = "Response.method"
idfields <- c(1:6)

## Spin out different kinds of fields (id, time received, modality)
id <- report[idfields]
report <- report[-idfields]

recfields <- grep(rectext, names(report))
rec <- report[recfields]
report <- report[-recfields]

modfields <- grep(modtext, names(report))
report <- report[-modfields]

stopifnot(
	(length(modfields) == length(rec))
	&& (length(report) == length(rec))
)

numResp <- sapply(rec, function(t){
	sum(!is.na(t) & t != "")
})

print(numResp)

## Select questions that look real
res <- numResp>1
rec <- rec[res]
report <- report[res]

summary(id)
summary(report)
summary(rec)

# rdsave(id, report, rec)
