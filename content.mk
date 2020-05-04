

######################################################################

## Mosaic:
## downcall dropdir/roster.xls

######################################################################

## avenueMerge
## Still developing
## Code that takes a whole spreadsheet to Avenue still in Tests/

## Put the final marking thing in a form that avenueMerge will understand
## midterms but not final merged with TAmarks for above this step
## FRAGILE (need to check quality checks)
## midterm2.grade.avenue.csv:
midterm%.grade.Rout: midterm%.merge.Rout finalscore.R
	$(run-R)

## Edit finalscore to match names for Avenue output
final.grade.Rout: final.patch.Rout finalscore.R
	$(run-R)

######################################################################
######################################################################

## Older stuff, currently unsuppressing
## Analysis stuff may still be suppressed here

Sources += grades.mk
