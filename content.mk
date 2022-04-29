

######################################################################

## Mosaic:
## downcall dropdir/roster.xls

######################################################################

## Merging test with scoresheet
## Patch IDs if necessary, 
## then make them numeric (for robust matching with TAs)
## The record in idpatch is an example, and may be out of date
Sources += idpatch.csv
## midterm1.patch.Rout: idpatch.R
%.patch.Rout: %.scores.Rout idpatch.csv idpatch.R
	$(run-R)


## avenueMerge
## Still developing
## Code that takes a whole spreadsheet to Avenue still in Tests/

######################################################################

## Merge SAs (from TA sheet) with patched scores (calculated from scantrons)
## Empty scores will be set to 0. Add MSAF to sheet as NA

## CHECK here for suspicious mismatches; if none, then just use bestScore?
## midterm2.merge.Rout: midMerge.R
midterm%.merge.Rout: midterm%.patch.Rout TAmarks.Rout midMerge.R
	$(run-R)

## Stuff to keep track of in terms of student-chasing.
Sources += testnotes.txt

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

## This takes anything with _score variables and makes a pre-Avenue csv
## final.grade.avenue.Rout: avenueMerge.R
## midterm2.grade.avenue.Rout: avenueMerge.R
## assign1.grade.avenue.Rout: avenueMerge.R
Ignore += *.avenue.Rout.csv
%.avenue.Rout: %.Rout sheetID.Rout avenueMerge.R
	$(run-R)

## avenueNA takes NA -> -. avenue treats these incorrectly as zeroes
## Avenue started giving me trouble with that as well, so now it just 
## drops all lines with NA (which is stupid, we could do it above)
## but then we'd have to worry about the logic set up for posting more than
## one score at once (which we don't use anyway)

## course.grade.avenue.csv: avenueNA.pl
## final.grade.avenue.csv: avenueNA.pl
## midterm2.grade.avenue.csv: avenueNA.pl
## assign3.grade.avenue.csv: avenueNA.pl
Ignore += *.avenue.csv
%.avenue.csv: %.avenue.Rout.csv avenueNA.pl
	$(PUSH)

######################################################################

## Dumping to clean Makefile 2022 Mar 08 (Tue)

## Spreadsheets with TA marks from HWs and SAs
## Make original spreadsheet from Avenue by downloading grades
## Need to do setup wizard, then Enter/Export?
## It doesn't work to go via classlist
## This apparently now (2020) prefixes the IDs with #; maybe make use of this convention
## 2021: NOw it prefixes the macids, too!
## Download (with first/last name)
## GEt rid of end field, extra #
## Convert to tsv for copy-paste (vim to gsheet)
## Match column names to previous year

## Import TA marks (manual) and change empties to zeroes
## This means you should add MSAFs as NAs before processing
## docs has history in the unlikely event we need it

## Merge the current classlist with the team sheet
## Losing the drops paradigm 2021 Apr 12 (Mon)
## Not doing this right now. 2022 Mar 08 (Tue)
sheetID.Rout: sheetID.R marks.tsv dropdir/classlist.csv
	$(pipeR)
TAmarks.Rout: TAmarks.R sheetID.rda
	$(pipeR)

## Web-only tests
## Click arrow next to quiz and choose "statistics"
## Download "User" statistics
## dropdir/midterm1.scores.csv ##
## dropdir/midterm2.scores.csv ##
## dropdir/final.scores.csv ##

## Code statements download mbox using https://takeout.google.com/
## Deselect all categories then select mail; it looks like mailboxes must be deselected by hand
## dropdir/final.code.zip ##
## unzip dropdir/final.code.zip "*/*/*.mbox" -d . ##
## ls */*/*.mbox ##
## mv */*/*.mbox final.mbox ##
## final.code.csv: final.mbox codebox.pl
Ignore += *.code.csv
%.code.csv: %.mbox codebox.pl
	$(PUSH)

## Manual additions to code list
Sources += midterm1.honor.csv
Sources += midterm2.honor.csv
Sources += final.honor.csv

## final.allcode.csv:
%.allcode.csv: %.code.csv %.honor.csv
	$(cat)

## Check for missing and extra pledges
## final.code.Rout: code.R final.allcode.csv dropdir/final.scores.csv
impmakeR += code
%.code.Rout: code.R %.allcode.csv dropdir/%.scores.csv
	$(pipeR)

## Merge with spreadsheet to handle NAs (MSAFs)
## Compare midMerge.R (the scantron, bubble-calc version)

# final.merge.Rout: merge.R
impmakeR += merge
%.merge.Rout: merge.R %.code.rda TAmarks.rda
	$(pipeR)

# Not really feeling very into Avenue posting right now
# Avenue-style scoring ## Need to see what works with idnum vs. macid
## final.testscore.Rout: testscore.R
impmakeR += testscore
%.testscore.Rout: testscore.R %.merge.rds
	$(pipeR)

# midterm1.testscore.avenue.Rout.csv: avenueMerge.R
# midterm2.testscore.avenue.Rout: avenueMerge.R

######################################################################

######################################################################

## Some of this is scantron stuff, I guess.

## Prep for Avenue
## merges into test and assignment pipelines being developed above
## there's also stuff below and in content.mk!!
## This takes anything with _score variables and makes a pre-Avenue csv
## final.grade.avenue.Rout: avenueMerge.R
## midterm2.grade.avenue.Rout: avenueMerge.R
## assign1.grade.avenue.Rout: avenueMerge.R
Ignore += *.avenue.Rout.csv
impmakeR += avenue
%.avenue.Rout: %.rds sheetID.rda avenueMerge.R
	$(run-R)

######################################################################

## Moved to content 2022 Mar 10 (Thu)
## Simple test stuff from pandemic I think.

## This pulls out the chosen score from a test merge and calls it what Avenue likes
## midterm2.grade.Rout:
midterm%.grade.Rout: midterm%.merge.Rout finalscore.R
	$(run-R)

final.grade.Rout: final.patch.Rout finalscore.R
	$(run-R)

course.grade.Rout: course.Rout courseGrade.R
	$(run-R)

######################################################################


## Final exam and final grade
## Regular scantron-exam stuff still in content.mk
final.patch.Rout: final_mark.csv finalAvenue.R
	$(run-R)
