## This is Bio3SS Marking, created 2020 Feb 21 (Fri)

current: target
-include target.mk

-include makestuff/perl.def

vim_session:
	bash -cl "vmt content.mk"

######################################################################

# Content

Sources += content.mk

Sources += $(wildcard *.R *.pl)

######################################################################

## dropdir is for sensitive products that I want to back up
## It has subdirectories for disks from MPS

Ignore += dropdir
## mkdir /home/dushoff/Dropbox/courses/3SS/2021
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2021
dropdir:
	$(linkdirname)
dropdir/%: 
	$(MAKE) dropdir

## mkdir /home/dushoff/Dropbox/courses/3SS/2020/final_disk ##
## /bin/cp -r /media/dushoff/*/*/* dropdir/final_disk/ ##
## mkdir dropdir/midterm1_disk/ ##
## downcall  dropdir/midterm1_disk/ ##

######################################################################

## Web-only tests
## Click arrow next to quiz and choose "statistics"
## Download "User" statistics

## dropdir/midterm1scores.csv

## dropdir/final_mark.csv
Ignore += final_mark.csv
final_mark.csv:
	/bin/ln -s dropdir/final_mark.csv

Sources += $(wildcard *.R *.pl)

######################################################################

## Spreadsheets with TA marks from HWs and SAs
## Make original spreadsheet from Avenue by downloading grades
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
## 2020
## https://docs.google.com/spreadsheeTS/D/1nErh7vg1PfOS3CYmZu5tQIjT-_Hsyi77S17zh4ZzeRQ/edit#gid=728284690 
## 2021
## https://docs.google.com/spreadsheets/d/1nErh7vg1PfOS3CYmZu5tQIjT-_Hsyi77S17zh4ZzeRQ/edit#gid=728284690
## downcall dropdir/marks.tsv  ##
Ignore += marks.tsv
marks.tsv: dropdir/marks.tsv zero.pl ##
	$(PUSH)

######################################################################

## Pipeline to mark and validate a set of scantrons
## Moving stuff back to content.mk

######################################################################

## Merge SAs (from TA sheet) with patched scores (calculated from scantrons)
## Empty scores will be set to 0. Add MSAF to sheet as NA

## CHECK here for suspicious mismatches; if none, then just use bestScore?
## midterm2.merge.Rout: midMerge.R
midterm%.merge.Rout: midterm%.patch.Rout TAmarks.Rout midMerge.R
	$(run-R)

Sources += testnotes.txt

######################################################################

## avenueMerge
## Still developing; right now I post things one at a time
## Code that takes a whole spreadsheet to Avenue still in Tests/

## Put the final marking thing in a form that avenueMerge will understand
## midterms but not final merged with TAmarks for above this step
## FRAGILE (need to check quality checks)

## This pulls out the chosen score from a test merge and calls it what Avenue likes
## midterm2.grade.Rout:
midterm%.grade.Rout: midterm%.merge.Rout finalscore.R
	$(run-R)

final.grade.Rout: final.patch.Rout finalscore.R
	$(run-R)

course.grade.Rout: course.Rout courseGrade.R
	$(run-R)

## Do the same for an assignment (COVID!)
## assign3.grade.Rout: assignscore.R
.PRECIOUS: assign%.grade.Rout
assign%.grade.Rout: TAmarks.Rout assignscore.R
	$(run-R)

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

## Click "import"
## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=315235

######################################################################

## Code pledges
## You can't get a final grade without a code pledge!
## No, that wasn't it!

code.Rout: dropdir/code.txt final_mark.csv code.R

######################################################################

## Polls

## Get PollEverywhere data:
## 	https://www.polleverywhere.com/reports
## 	Create reports
## 	Participant response history
## 	Select groups for this year
## 	Download csv (lower right)

## To repeat:
##		Reports / select report you want / Update reports (next to Current Run at top)

##	downcall dropdir/polls.csv ##

######################################################################

# Read the polls into three variables

polls.Rout: dropdir/polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the question that matches "macid" as a fake (if present)
# and use it to help with ID
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
# The csv is where to look for orphan lines and try to figure out if people are missing points they should get
# Then loop back to the manual part of the .ssv

Sources += extraPolls.ssv
## Make an empty extraPolls automatically
dropdir/%.ssv: 
	$(CP) $*.ssv $@
## del dropdir/extraPolls.ssv ##

pollScore.Rout: dropdir/extraPolls.ssv parsePolls.Rout pollScore.R
pollScore.Rout.csv: 

## Provisional poll scores

pollScore.avenue.Rout: avenueMerge.R
pollScore.avenue.Rout.csv: avenueMerge.R

# Ask people to answer a fake question with "macid" in it
# in all the ways that they answered the polls
# Then save people manually in column 3 of .ssv

# Merge to save people who repeatedly use student number
## Why not working? 2019 Apr 29 (Mon)
## Patched, but not doing anything. Because people know what macid is now? remove?
pollScorePlus.Rout: pollScore.Rout sheetID.Rout pollScorePlus.R

## import

pollScorePlus.avenue.Rout: avenueMerge.R
pollScorePlus.avenue.Rout.csv: avenueMerge.R

pollScorePlus.avenue.csv: avenueNA.pl

######################################################################

## Final exam and final grade
## Regular scantron-exam stuff still in content.mk

final.patch.Rout: final_mark.csv finalAvenue.R
	$(run-R)

## Read and combine different mark sources

tests.Rout: TAmarks.Rout midterm1.merge.Rout.envir midterm2.merge.Rout.envir final.patch.Rout.envir tests.R

## Final grade: 
## Check weightings, number of assignments, components, etc.
## course.Rout.csv: course.R
course.Rout: gradeFuns.Rout tests.Rout pollScorePlus.Rout TAmarks.Rout course.R

######################################################################

## Mosaic

## Go to course through faculty center
## https://epprd.mcmaster.ca/psp/prepprd/EMPLOYEE/SA/c/SA_LEARNING_MANAGEMENT.SS_FACULTY.GBL?pslnkid=MCM_WC_FCLT_CNTR
## You can download as EXCEL (upper right of roster display)
## and upload as CSV

## downcall dropdir/mosaic.xls ## Insanity! This is an html file that cannot be read by R AFAICT, even though it opens fine in Libre ##
## downcall dropdir/mosaic.csv
## It would be better to change some of the code here and keep the
## student numbers as strings

## CHECK class number (needs to be cribbed from Mosaic and entered here)
## Check dropCandidates in Rout

mosaic_grade.Rout: dropdir/mosaic.csv course.Rout mosaic_grade.R
## mosaic_grade.Rout.csv: mosaic_grade.R

## Upload this .csv to mosaic
## Faculty center, online grading tab
## ~/Downloads/grade_guide.pdf ##
## There is no guidance about students with incomplete marks; let's see what happens

## Copy grades to dropdir for diffing:
#### cp mosaic_grade.Rout.csv dropdir ##
Ignore += grade.diff
grade.diff: mosaic_grade.Rout.csv dropdir/mosaic_grade.Rout.csv
	$(diff)

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
