pardirs += Tests

Ignore += $(pardirs)

## Notes on scantron files
Sources += media.md

## Add rows manually to the .tsv file if sheets don't scan
## Or for deferred finals 
## scanning
## dropdir/midterm2.manual.tsv:
dropdir/%.manual.tsv:
	$(touch)

## Student itemized responses
## Script reads manual version first, ignores repeats
## Necessitated by Daniel Park!
## Match .dlm format
Ignore += *.responses.tsv
## midterm2.responses.tsv: rmerge.pl
%.responses.tsv: dropdir/%.manual.tsv dropdir/%_disk/BIOLOGY*.dlm rmerge.pl
	$(PUSH)

## Our scores
Ignore += $(wildcard *.scoring.csv)
### Formatted key sheet (made from scantron.csv)
## cd Tests && make midterm1.scantron.csv ## to stop making forever ##
## midterm2.scoring.csv:
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

## Score the students
## How many have weird bubble versions? How many have best ≠ bubble?
## midterm2.scores.Rout:  scores.R
%.scores.Rout: %.responses.tsv %.scoring.csv scores.R
	$(run-R)

## Compare with office scores
## Scantron-office scores
Ignore += *.office.csv
## midterm1.office.csv: 
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## 2020 Feb 24 (Mon): Lots of version problems ☹
## midterm2.scorecomp.Rout: scorecomp.R
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)


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
