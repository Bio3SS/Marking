

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

## Combined course grading
## Score merging
## Read stuff from different sources into a complete table

tests.Rout: TAmarks.Rout midterm1.merge.Rout.envir midterm2.merge.Rout.envir final.patch.Rout.envir tests.R

## Check weightings, number of assignments, components, etc.
## course.Rout.csv: course.R
course.Rout: gradeFuns.Rout tests.Rout pollScorePlus.Rout TAmarks.Rout course.R

## Mosaic

## Go to course through faculty center
## You can download as EXCEL (upper right of roster display)
## and upload as CSV

## downcall dropdir/mosaic.xls ## Insanity! This is an html file that cannot be read by R AFAICT, even though it opens fine in Libre ##
## downcall dropdir/mosaic.csv

## Check class number 
## Check dropCandidates in Rout
## mosaic_grade.Rout.csv: mosaic_grade.R
mosaic_grade.Rout: dropdir/mosaic.csv course.Rout mosaic_grade.R
## Upload this .csv to mosaic
## Faculty center, online grading tab
## ~/Downloads/grade_guide.pdf
## There is no guidance about students with incomplete marks; let's see what happens

## Copy grades to dropdir for diffing:
#### cp mosaic_grade.Rout.csv dropdir ##
Ignore += grade.diff
grade.diff: mosaic_grade.Rout.csv dropdir/mosaic_grade.Rout.csv
	$(diff)

######################################################################

## Older stuff, currently unsuppressing
## Analysis stuff may still be suppressed here

Sources += grades.mk
