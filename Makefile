## This is Bio3SS Marking, created 2020 Feb 21 (Fri)

current: target
-include target.mk

-include makestuff/perl.def

######################################################################

# Content

Sources += content.mk

Sources += $(wildcard *.R *.pl)

######################################################################

## dropdir is for sensitive products that I want to back up
## It has subdirectories for disks from MPS

## mkdir /home/dushoff/Dropbox/courses/3SS/2019/final_disk ##
## /bin/cp -r /media/dushoff/*/*/* dropdir/final_disk/ ##
## mkdir dropdir/midterm1_disk/ ##
## downcall  dropdir/midterm1_disk/ ##

Sources += $(wildcard *.R *.pl)

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2020
dropdir:
	$(linkdirname)
dropdir/%: 
	$(MAKE) dropdir

######################################################################

### Cribbing

.PRECIOUS: %.pl
%.pl:
	$(CP) ../Grading/$@ .
	$(RW)

.PRECIOUS: %.R
%.R:
	$(CP) ../Grading/$@ .
	$(RW)

######################################################################

## Spreadsheets with TA marks from HWs and SAs
## Make original spreadsheet from Avenue by downloading grades
## It doesn't work to go via classlist
## This apparently now (2020) prefixes the IDs with #; maybe make use of this convention

## Import TA marks (manual) and change empties to zeroes
## Use named versions of marks.tsv (no revision control in Dropbox)
## https://docs.google.com/spreadsheets/d/1nErh7vg1PfOS3CYmZu5tQIjT-_Hsyi77S17zh4ZzeRQ/edit#gid=728284690
## downcall dropdir/marks1.tsv  ##
Ignore += marks.tsv
marks.tsv: dropdir/marks1.tsv zero.pl ##
	$(PUSH)

######################################################################

## Pipeline to mark and validate a set of scantrons

pardirs += Tests

Ignore += $(pardirs)

## Notes on scantron files
Sources += media.md

## Add rows manually to the .tsv file if sheets don't scan
## Or for deferred finals 
## scanning
dropdir/%.manual.tsv:
	$(touch)

## Student itemized responses
## Script reads manual version first, ignores repeats
## Necessitated by Daniel Park!
Ignore += *.responses.tsv
## midterm1.responses.tsv: rmerge.pl
%.responses.tsv: dropdir/%.manual.tsv dropdir/%_disk/BIOLOGY*.dlm rmerge.pl
	$(PUSH)

## Scantron-office scores
Ignore += *.office.csv
## midterm1.office.csv: 
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## Our scores
Ignore += $(wildcard *.scoring.csv)
### Formatted key sheet (made from scantron.csv)
## cd Tests && make midterm1.scantron.csv ## to stop making forever ##
## midterm1.scoring.csv:
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

## Score the students
## How many have weird bubble versions? How many have best ≠ bubble?
## midterm1.scores.Rout:  midterm1.responses.tsv midterm1.scoring.csv scores.R
%.scores.Rout: %.responses.tsv %.scoring.csv scores.R
	$(run-R)

## Compare

## midterm1.scorecomp.Rout: midterm1.office.csv midterm1.scores.Rout scorecomp.R
## 2020 Feb 24 (Mon): Lots of version problems ☹
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)

######################################################################

## Merging test with scoresheet
## Patch IDs if necessary, 
## then make them numeric (for robust matching with TAs)
## The record in idpatch is an example, and may be out of date
Sources += idpatch.csv
%.patch.Rout: %.scores.Rout idpatch.csv idpatch.R
	$(run-R)
## midterm1.patch.Rout: idpatch.R

## Parse out TAmarks, drop students we think have dropped
## Used Avenue import info; this could be improved by starting from that
## Pull a subset of just student info
Sources += nodrops.csv
dropdir/drops.csv: 
	$(CP) nodrops.csv $@
TAmarks.Rout: marks.tsv dropdir/drops.csv TAmarks.R

## Merge SAs (from TA sheet) with patched scores (calculated from scantrons)
## Set numeric to merge here. Pad somewhere downstream
## Check anomalies from print out
## Empty scores will be set to 0. Add MSAF to sheet (as NA?) 
## midterm1.merge.Rout: midMerge.R
midterm%.merge.Rout: midterm%.patch.Rout TAmarks.Rout midMerge.R
	$(run-R)

######################################################################


## Polls

## Get PollEverywhere data:
## 	https://www.polleverywhere.com/reports / Create reports
## 	Participant response history
## 	Select groups for this year
## 	Download csv (lower right)

## To repeat:
##		Reports / select report you want / Update reports (next to Current Run at top)

##	downcall dropdir/polls.csv ##

######################################################################

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff
Makefile: makestuff/Makefile
makestuff/Makefile:
	git clone $(msrepo)/makestuff
	ls $@

-include makestuff/os.mk

-include makestuff/wrapR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
