
## Polls

## Get PollEverywhere data:
## 	https://www.polleverywhere.com/reports
## 	Create reports
## 	Participant response history
## 	Select groups for this year (include one fake macid question!)
## 	Download csv (lower right)

## To repeat:
##		Reports / select report you want / Update reports (next to Current Run at top)

##	dropdir/polls.csv ##

######################################################################

# Read the polls into three variables
## Go through this step by step and figure out what PollEverywhere has changed ☹
polls.Rout: polls.R dropdir/polls.csv
	$(pipeR)

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the question that matches "macid" as a fake (if present)
# and use it to help with ID
parsePolls.Rout: parsePolls.R polls.rda
	$(pipeR)

# Calculate a pollScore and combine with the extraScore made by hand
# The csv is where to look for orphan lines and try to figure out if people are missing points they should get
# Then loop back to the manual part of the .ssv

## Edit extraPolls on dropdir; reset each year below
## Github version should be kept blank
## dropdir/extraPolls.ssv.rmk:
Sources += extraPolls.ssv
dropdir/%.ssv: 
	$(CP) $*.ssv $@

## Score polls and print a report about UNKNOWN scores
## Look in the csv for unlinked scores to add to the manual column of extraPolls
## dropdir/extraPolls.ssv
## This whole thing is a bit loopy; we should probably parse, then make the manual, then add things up.

## pollScore.grade.Rout.csv: pollScore.R
pollScore.grade.Rout: pollScore.R dropdir/extraPolls.ssv parsePolls.rda
	$(pipeR)

## Provisional poll scores

## Some sort of chaining problem here; impmakeR?
## pollScore.avenue.Rout: avenue.R
## pollScore.avenue.Rout.csv: avenueNA.pl

# Ask people to answer a fake question with "macid" in it
# in all the ways that they answered the polls
# Then save people manually in column 3 of .ssv

## pollScorePlus was an attempt to rescue using student number
## Ditching because it confused me 2021 Apr 28 (Wed)

######################################################################
