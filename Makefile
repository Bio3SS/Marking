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

## dropdir is for anything downloaded
## But also for stuff we edit with student info
## Scantron transmittals from MPS are subdirectories
## It could be better to have a private-subrepo for stuff I do by hand …
## Implicit rules can sometimes delete dropdir files if they need to make dropdir, so don't chain; make dropdir manually (once per machine per year)
## | dependencies might fix this

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2022
dropdir:
	$(linkdirname)

## MPS transfer examples
## mkdir dropdir/final_disk/ ##
## downcall  dropdir/final_disk/ ##
## cd dropdir/final_disk/ && lastunzip ##
## mv ~/Downloads/scantron dropdir/midterm2_disk ##

######################################################################

## Make classlist from Avenue by downloading grades
## Need to do setup wizard, then Enter/Export?
## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/importexport/export/options_edit.d2l?ou=413706

## Update classlist and use to address drops and adds
## dropdir/classlist.csv

######################################################################

## Marks (does assignments prepares tests)
## Start the spreadsheet with the classlist

## https://docs.google.com/spreadsheets/d/1wGko_PoF90LTfOuYN6fkFqkAFNjzzDS0xkTI3qzx8lo/
## dropdir/marks.tsv  ##

## Convert (unexplained) blanks to zeroes
## Note: this now affects notes, too; weird but not harmful, i think
Ignore += marks.tsv
marks.tsv: dropdir/marks.tsv zero.pl ##
	$(PUSH)

## Parse the marks sheet (builds through semester as marks are added)
## Merge in classlist (which updates with add/drop)
marks.Rout: marks.R marks.tsv dropdir/classlist.csv

######################################################################

## Posting to Avenue
## Pull a single assignment score

impmakeR += grade
## assign2.grade.Rout: assignscore.R
impmakeR += grade
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
## avenue is no longer stupid about NAs (flags them but continues the import), so this step is only aesthetic now.

## assign3.avenue.csv: avenueNA.pl
Ignore += *.avenue.csv
%.avenue.csv: %.avenue.Rout.csv avenueNA.pl
	$(PUSH)

## Click "import"
## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=413706

######################################################################

## Pipeline to mark and validate a set of scantrons
## See also content.mk 
## Notes
Sources += media.md

pardirs += Tests

## Add rows manually to the .tsv file if sheets don't scan!!!!
## dropdir/midterm2.manual.tsv:
dropdir/%.manual.tsv:
	$(touch)

## Student itemized responses
## 2022 Apr 28 (Thu) Ditching the merge in rmerge; instead make a copy and edit it in the Dropbox
## EDIT .scanned.tsv NOT the original .dlm

.PRECIOUS: dropdir/%.scanned.tsv
## dropdir/final.scanned.tsv: 
dropdir/%.scanned.tsv: | dropdir/%_disk/BIOLOGY*.dlm
	$(pcopy)

Ignore += *.responses.tsv
## final.responses.tsv: rmerge.pl dropdir/final.scanned.tsv

## rmerge no longer merges, but does catch some ID errors
Ignore += %.responses.tsv
%.responses.tsv: dropdir/%.scanned.tsv rmerge.pl
	$(PUSH)

######################################################################

## Score the tests here (and compare with scantron score)
Ignore += $(wildcard *.scoring.csv)
### Formatted key sheet (made from scantron.csv)
## cd Tests && make midterm1.scantron.csv ## to stop making forever ##
## final.scoring.csv: Tests/final.scantron.csv scoring.pl
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

Tests/%: | Tests
	$(justmakethere)

## Score the students (ancient, deep matching)
## How many have weird bubble versions? How many have best ≠ bubble?
## final.scores.rtmp:  scores.R
## midterm2.scores.Rout: scores.R
## midterm2.scores.Rout: midterm2.responses.tsv midterm2.scoring.csv
impmakeR += scores
%.scores.Rout: scores.R %.responses.tsv %.scoring.csv
	$(pipeR)

## Compare with Scantron-office scores (side branch)

## Scantron-office scores do not exist for people with idnum problems
Ignore += *.office.csv
## final.office.csv:
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## final.scorecomp.Rout: scorecomp.R
impmakeR += scorecomp
%.scorecomp.Rout: %.office.csv %.scores.rds scorecomp.R
	$(pipeR)

######################################################################

## Merge MC with SA scores
## Who has an SA but not MC? Use to fix errors
## Also doing a version of avenue csv here

impmakeR += merge
## midterm2.merge.Rout: midMerge.R
impmakeR += merge
midterm%.merge.Rout: midMerge.R midterm%.scores.rds marks.rds
	$(pipeR)

## final.merge.Rtmp: merge.R final.scores.rds marks.rds
final.merge.Rout: merge.R final.scores.rds marks.rds
	$(pipeR)

impmakeR += grade
## midterm2.grade.Rout: midtermGrade.R
midterm%.grade.Rout: midtermGrade.R midterm%.merge.rds
	$(pipeR)

## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=413706
## midterm2.avenue.Rout: avenue.R
## midterm2.avenue.Rout.csv: avenue.R

######################################################################

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

## pollScore.grade.Rout.csv:  pollScore.R
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

## Final exam and final grade

gradeFuns.Rout: gradeFuns.R
	$(wrapR)

## Read and combine different mark sources
tests.Rout: tests.R midterm1.merge.rds midterm2.merge.rds
	$(pipeR)

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

## Exam Question statistics from scantron peeps
## Fix stats.html weirdness?

Ignore += questions*.html
## questions2.html: stats.pl
questions%.html: stats.pl dropdir/midterm%_disk/QuestionStatistics.html
	$(PUSH)

## Now doing this with a manual CP, because there is a binary encoding step as well? Or what?

Ignore += stats*.html
## stats2.html: dropdir/stats2.html stats.pl
stats%.html: dropdir/stats%.html stats.pl
	$(PUSH)

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
