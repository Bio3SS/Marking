## This is Bio3SS Marking, created 2020 Feb 21 (Fri)
## Refactor (different .mk files for polls, web tests, etc?)

current: target
-include target.mk

-include makestuff/perl.def

vim_session:
	bash -cl "vmt content.mk"

######################################################################

## Older rules (moving back and forth 2022 Mar 10 (Thu))
Sources += content.mk

Sources += $(wildcard *.R *.pl)

autopipeR = defined

######################################################################

## dropdir is for sensitive products that I want to back up
## It has subdirectories for disks from MPS

Ignore += dropdir
## mkdir /home/dushoff/Dropbox/courses/3SS/2022 ##
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2022
dropdir:
	$(linkdirname)
dropdir/%: 
	$(MAKE) dropdir

## mkdir dropdir/midterm1_disk/ ##
## downcall  dropdir/midterm1_disk/ ##
## cd dropdir/midterm1_disk/ && lastunzip ##

######################################################################

## https://docs.google.com/spreadsheets/d/1wGko_PoF90LTfOuYN6fkFqkAFNjzzDS0xkTI3qzx8lo/
## dropdir/marks.tsv  ##

## Convert (unexplained) blanks to zeroes
## Note: this now affects notes, too.
Ignore += marks.tsv
marks.tsv: dropdir/marks.tsv zero.pl ##
	$(PUSH)

## Parse the marks sheet (builds through semester as marks are added)
marks.Rout: marks.R marks.tsv

######################################################################

## Make classlist from Avenue by downloading grades
## Need to do setup wizard, then Enter/Export?
## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/importexport/export/options_edit.d2l?ou=413706

## Update classlist and use to ignore drops. sometimes.
## dropdir/classlist.csv

######################################################################

## Posting to Avenue
## Pull a single assignment score

## Click "import"
## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=413706

impmakeR += grade
## assign1.grade.Rout: assignscore.R
.PRECIOUS: assign%.grade.Rout
assign%.grade.Rout: marks.rds assignscore.R
	$(pipeR)

## Simplifying, will it work? 2022 Mar 08 (Tue)
## assign1.avenue.Rout: avenue.R
## assign1.avenue.Rout.csv: avenue.R
impmakeR += avenue
%.avenue.Rout: %.grade.rds avenue.R
	$(pipeR)

## avenueNA takes NA -> -. avenue treats these incorrectly as zeroes
## Avenue started giving me trouble with that as well, so now it just 
## drops all lines with NA (which is stupid, we could do it above)
## but then we'd have to worry about the logic set up for posting more than
## one score at once (which we don't use anyway)

## assign1.avenue.csv: avenueNA.pl
Ignore += *.avenue.csv
%.avenue.csv: %.avenue.Rout.csv avenueNA.pl
	$(PUSH)

######################################################################

## Pipeline to mark and validate a set of scantrons
## See also content.mk 
## Notes
Sources += media.md

pardirs += Tests

## Add rows manually to the .tsv file if sheets don't scan
## dropdir/midterm2.manual.tsv:
dropdir/%.manual.tsv:
	$(touch)

## Student itemized responses
## Script reads manual version first, ignores repeats
## Necessitated by Daniel Park!
## Match .dlm format
Ignore += *.responses.tsv
## midterm1.responses.tsv: rmerge.pl
%.responses.tsv: dropdir/%.manual.tsv dropdir/%_disk/BIOLOGY*.dlm rmerge.pl
	$(PUSH)

######################################################################

## Our scores
Ignore += $(wildcard *.scoring.csv)
### Formatted key sheet (made from scantron.csv)
## cd Tests && make midterm1.scantron.csv ## to stop making forever ##
## midterm1.scoring.csv: Tests/midterm1.scantron.csv scoring.pl
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

## Score the students (ancient, deep matching)
## How many have weird bubble versions? How many have best ≠ bubble?
## midterm1.scores.rtmp:  scores.R
## midterm1.scores.Rout:  scores.R
%.scores.Rout: scores.R %.responses.tsv %.scoring.csv
	$(pipeR)

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

polls.Rout: dropdir/polls.csv polls.R
	$(wrapR)

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the question that matches "macid" as a fake (if present)
# and use it to help with ID
parsePolls.Rout: polls.rda parsePolls.R
	$(wrapR)

# Calculate a pollScore and combine with the extraScore made by hand
# The csv is where to look for orphan lines and try to figure out if people are missing points they should get
# Then loop back to the manual part of the .ssv

Sources += extraPolls.ssv
## Make an empty extraPolls automatically
dropdir/%.ssv: 
	$(CP) $*.ssv $@
## del dropdir/extraPolls.ssv ##

pollScore.Rout: extraPolls.ssv parsePolls.rda pollScore.R
	$(pipeR)
## pollScore.Rout.csv:  pollScore.R

## Provisional poll scores

## Some sort of chaining problem here; impmakeR?
## pollScore.avenue.Rout: avenueMerge.R
## pollScore.avenue.csv: avenueNA.pl

# Ask people to answer a fake question with "macid" in it
# in all the ways that they answered the polls
# Then save people manually in column 3 of .ssv

## pollScorePlus was an attempt to rescue using student number
## Ditching becasue it confused me 2021 Apr 28 (Wed)

######################################################################

## Final exam and final grade
## Regular scantron-exam stuff still in content.mk
final.patch.Rout: final_mark.csv finalAvenue.R
	$(run-R)

## Read and combine different mark sources

tests.Rout: tests.R TAmarks.rda midterm1.merge.rds midterm2.merge.rds final.merge.rds
	$(pipeR)

gradeFuns.Rout: gradeFuns.R
	$(wrapR)

## Final grade: 
## Check weightings, number of assignments, components, etc.
## course.Rout.csv: course.R
course.Rout: gradeFuns.rda tests.rds pollScore.rds TAmarks.rda course.R
	$(pipeR)

## 2021 special-purpose (final grades to Avenue)
## courseAvenue.Rout.csv: courseAvenue.R
courseAvenue.Rout: courseAvenue.R course.rds
	$(pipeR)

######################################################################

## Mosaic

## Go to course through faculty center
## https://epprd.mcmaster.ca/psp/prepprd/EMPLOYEE/SA/c/SA_LEARNING_MANAGEMENT.SS_FACULTY.GBL?pslnkid=MCM_WC_FCLT_CNTR
## You can download as EXCEL (upper right of roster display)
## and upload as CSV

dropdir/mosaic.xls: HTML document, ASCII text
## downcall dropdir/mosaic.xls ## Insanity! This is an html file that cannot be read by R AFAICT, even though it opens fine in Libre ##
## FAiled again 2021 Apr 28 (Wed) (readxl)
## downcall dropdir/mosaic.csv
## It would be better to change some of the code here and keep the
## student numbers as strings

## CHECK class number (needs to be cribbed from Mosaic and entered here)

mosaic_grade.Rout: dropdir/mosaic.csv course.rds mosaic_grade.R
	$(pipeR)
## mosaic_grade.Rout.csv: mosaic_grade.R

## Upload this .csv to mosaic
## Faculty center, online grading tab

## Copy grades to dropdir for diffing:
#### cp mosaic_grade.Rout.csv dropdir ##
Ignore += grade.diff
grade.diff: mosaic_grade.Rout.csv dropdir/mosaic_grade.Rout.csv
	$(diff)

######################################################################

Ignore += $(pardirs)

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

-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
