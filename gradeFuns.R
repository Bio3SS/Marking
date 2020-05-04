
powerAve <- function(scores, dens, weights, downgrade=0){
	## scores <- ifelse(scores==avenueMissing, 0, scores)
	## scores <- ifelse(scores==avenueMSAF, NA, scores)
	power <- sum(sign(1+scores), na.rm=TRUE)
	power <- (power+downgrade)/(1+downgrade) 
	weight <- sum(sign(1+scores)*weights, na.rm=TRUE)
	scores <- scores/dens
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

oddsCurve <- function(score, rho, points){
	T = score/points
	Tp = rho*T/(1-T+rho*T)
	return(points*Tp)
}
