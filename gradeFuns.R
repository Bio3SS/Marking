
powerAve <- function(scores, dens, weights=dens, rho=NULL, downgrade=0){
	power <- sum(sign(scores), na.rm=TRUE)
	power <- (power+downgrade)/(1+downgrade) 
	weight <- sum(sign(1+scores)*weights, na.rm=TRUE)
	scores <- scores/dens
	if (weight==0 | sum(scores, na.rm=TRUE)==0) return(0)
	if(!is.null(rho)) scores <- oddsCurve(scores, rho)
	tot <- sum(scores^power*weights, na.rm=TRUE)
	return((tot/weight)^(1/power))
}

# average while dropping lowest something (for optional assignments)
dropAve <- function(scores, dens, downgrade=10){
	perc <- scores/dens
	drop <- which.min(perc)[[1]]
	scores[[drop]] <- NA
	return(powerAve(scores, dens, weights=1, downgrade=downgrade))
}

naZero <- function(v){
	return(ifelse(is.na(v), 0, v))
}

oddsCurve <- function(score, rho){
	return(rho*score/(1-score+rho*score))
}
