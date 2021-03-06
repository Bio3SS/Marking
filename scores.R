library(readr)
library(dplyr)

## Read stuff in
responses <- read_tsv(grep("tsv", input_files, value=TRUE)
	, col_names=FALSE
)

key <- read_csv(grep("csv", input_files, value=TRUE))

answers <- as.matrix(responses[-(1:2)])
answers <- matrix(match(answers, LETTERS), nrow=nrow(answers))
dim(answers)
summary(answers)

versions = unique(key$Version)
scores <- matrix(nrow=nrow(answers), ncol=length(versions))
for (ver in versions){
	vkey <- (key
		%>% filter(Version==ver)
		%>% select(-(1:2))
		%>% as.matrix()
	)
	## Can't figure out how to deloop this
	scores [ ,ver] <- apply(answers, 1, function(a){
		for(i in 1:length(a)){
			a[[i]] <- ifelse(!is.na(a[[i]]), vkey[[i, a[[i]]]], 0)
		}
		return(sum(a))
	})
}

## Pick out best version and highest score
## which.max makes a confusing object for an unclear reason
bestScore <- apply(scores, 1, max)
bestVer <- unlist(apply(scores, 1, which.max))

summary(bestScore)
summary(bestVer)

## Try to instead get a score for the bubbled version
## Look here for mismatches
bubbleVersion <- pull(responses, X2)
print(table(bubbleVersion))

## Um...
## bubbleVersion[bubbleVersion==44] <- 4

print(sum(bubbleVersion != bestVer))
print(sum(bubbleVersion < 0))

verScore <- sapply(1:nrow(scores), function(i){
	if (bubbleVersion[[i]]<0) return(0)
	return(scores[[i, bubbleVersion[[i]]]])
})

scores <- (responses
	%>% transmute(idnum=X1
		, bubVer=X2
		, bestScore
		, bestVer
		, verScore
	)
)
summary(scores)

# rdsave(scores)
