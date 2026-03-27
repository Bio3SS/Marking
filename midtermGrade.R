library(dplyr)

library(shellpipes)

loadEnvironments()

rho <- c(1.4, 1.4)

v <- pipeStar()

scores <- (rdsRead()
	%>% transmute(Username
		, total_score = oddsCurve(SA+MC, rho=rho[[as.numeric(v)]], max=25)
		, SA_score=SA, MC_score=MC
	)
	%>% setNames(sub("(.*_score)", paste0("M", v, "\\1"), names(.)))
)

summary(scores)
rdsSave(scores)
