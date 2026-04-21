## This is Bio3SS Marking, created 2020 Feb 21 (Fri)
## Refactor (different .mk files for polls, web tests, etc?)

current: target
-include target.mk

-include makestuff/perl.def

vim_session:
	bash -ic "vmt journal.md content.mk"

######################################################################

## Older rules (moving back and forth 2022 Mar 10 (Thu))
Sources += content.mk

Sources += $(wildcard *.R *.pl)

autopipeR = defined

######################################################################

## ARCHIVE first

## dropdir is for anything downloaded
## But also for stuff we edit with student info
## Scantron transmittals from MPS are subdirectories
## It could be better to have a private-subrepo for stuff I do by hand …
## Implicit rules can sometimes delete dropdir files if they need to make dropdir, so don't chain; make dropdir manually (once per machine per year)

## Think more about archiving: probably Ignore dropdir and link it to a year directory

oldmirrors += 2024
mirrors += dropdir

## This is just craziness; moves for one computer at a time, does not seem to archive??
## Remake dropdir for new term ## Also ADD to oldmirrors
## /home/dushoff/Dropbox/courses/3SS/2022 for previous
## 2024.old ## Not tested
%.old:
	$(MV) dropdir $*;
	$(MAKE) dropdir
Ignore += dropdir
Ignore += $(oldmirrors)

## MPS transfer (manual because it uses bash aliases, could be fixed)
## mkdir dropdir/midterm1_disk/ ##
## downcall dropdir/midterm1_disk/ ##
## cd dropdir/midterm1_disk/ && lastunzip ##
## mkdir dropdir/midterm2_disk/ ##
## downcall dropdir/midterm2_disk/ ##
## cd dropdir/midterm2_disk/ && lastunzip ##
## mkdir dropdir/final_disk/ ##
## downcall dropdir/final_disk/ ##
## cd dropdir/final_disk/ && lastunzip ##

######################################################################

## Update classlist and use to address drops and adds
## Make classlist from Avenue by downloading grades
## Need to do setup wizard, then Enter/Export?
## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/importexport/export/options_edit.d2l?ou=757445
## Choose “both” for identifiers.
## Moving towards downloading assignment grades at the same time! 2026 Apr 19 (Sun)
## Select radio box for “points grade”

## dropdir/classlist.csv

######################################################################

## Marks (does assignments prepares tests)
## Start the spreadsheet with the classlist
## Fill in MSAFs here

## Make a separate “export” sheet for stuff that goes here

## https://docs.google.com/spreadsheets/d/15yTrBN51QBKRDrFTJPgYx9S_sviIt9rWbEx1_o5XMuo/edit
## Use download as tsv and then gD.
## dropdir/marks.tsv ##

## Convert (unexplained) blanks to zeroes
## Note: this now affects notes, too; weird but not harmful, i think
Ignore += marks.tsv
marks.tsv: dropdir/marks.tsv zero.pl ##
	$(PUSH)

## Parse the marks sheet (builds through semester as marks are added)
## Merge in classlist (which updates with add/drop)
## Rebuild 2026 because assignments are now on Avenue (via classlist)
marks.Rout: marks.R marks.tsv dropdir/classlist.csv
	$(pipeR)

######################################################################

## Deleted machinery for sheet-based assignment scores (we now have avenue-based assignment scores, but sheet-based MSAF notes for them)

######################################################################

## Pipeline to mark and validate a set of scantrons
## See also content.mk 
## Notes about scantron disks
Sources += media.md

pardirs += Tests

## Student itemized responses
## To fix mistakes:
## EDIT .scanned.tsv NOT the original .dlm

.PRECIOUS: dropdir/%.scanned.tsv
## dropdir/final.scanned.tsv: 
dropdir/%.scanned.tsv: | dropdir/%_disk/BIOLOGY*.dlm
	$(pcopy)

Ignore += *.responses.tsv
## rmerge no longer merges, but does catch some ID errors
## It could be used to look at version numbers I guess
## midterm1.responses.tsv: rmerge.pl 
## midterm2.responses.tsv: rmerge.pl
## final.responses.tsv: rmerge.pl
Ignore += %.responses.tsv
%.responses.tsv: dropdir/%.scanned.tsv dropdir/%.manual.tsv rmerge.pl
	$(PUSH)

Ignore += *.manual.tsv
## midterm1.manual.tsv: manual.pl
## midterm2.manual.tsv: manual.pl dropdir/midterm2.manual.txt
	
%.manual.tsv: $(wildcard dropdir/*.manual.txt) manual.pl
	$(PUSH)

######################################################################

## Score the tests here (and compare with scantron score)
### PUSH the CORRECT scantron file in Tests first
### There are apparently two possible scantron csv files (allkeys allows more versions, for delayed SAS)
### [Don't want to accidentally update scantrons when test banks change]

### Formatted key sheet (made from scantron.csv)
## midterm1.scoring.csv: scoring.pl
## midterm2.scoring.csv: scoring.pl
## final.scoring.csv: scoring.pl
Ignore += $(wildcard *.scoring.csv)
.PRECIOUS: %.scoring.csv
## %.scoring.csv: Tests/outputs/%.allkeys.csv scoring.pl
%.scoring.csv: Tests/outputs/%.scantron.csv scoring.pl
	$(PUSH)

## Score the students (ancient, deep matching)
## How many have weird bubble versions? How many have best ≠ bubble?
## midterm1.scores.Rout: scores.R
## midterm1.scores.Rout: midterm1.responses.tsv midterm1.scoring.csv
## midterm2.scores.Rout: scores.R
## final.scores.Rout: scores.R
impmakeR += scores
%.scores.Rout: scores.R %.responses.tsv %.scoring.csv
	$(pipeR)

## Share responses with students
Ignore += *.bubbles.csv
## midterm1.bubbles.csv: bubbles.pl
## midterm2.bubbles.csv: bubbles.pl
## final.bubbles.csv: bubbles.pl
%.bubbles.csv: bubbles.pl %.responses.tsv
	$(PUSH)

## Look at these tables (and also MPS-based tables below), fix problems and decide which score to use going forward (bestScore or verScore)
## In general, best to fix enough problems that you can use verScore

## Scantron-office scores do not exist for people with idnum problems
Ignore += *.office.csv
## midterm1.office.csv:
## midterm2.office.csv:
## final.office.csv:
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## midterm1.scorecomp.Rout: scorecomp.R
## midterm2.scorecomp.Rout: scorecomp.R
## final.scorecomp.Rout: scorecomp.R
impmakeR += scorecomp
%.scorecomp.Rout: %.office.csv %.scores.rds scorecomp.R
	$(pipeR)

######################################################################

Sources += $(wildcard *.md)
## Keep track of fixes and decisions in journal.md

######################################################################

## Merge MC with SA scores
## Who has an SA but not MC? Use to fix errors
## Also: choose here whether to use verScore (after complete QC) or else bestScore
## Also doing a version of avenue csv here

impmakeR += merge
## midterm1.merge.Rout: midMerge.R
## midterm2.merge.Rout: midMerge.R
## final.merge.Rout: midMerge.R
impmakeR += merge
midterm%.merge.Rout: midMerge.R midterm%.scores.rds marks.rds
	$(pipeR)

## Scan for people who didn't write final; add deferred marks as appropriate
Sources += deferred.tsv
final.merge.Rout: finalMerge.R final.scores.rds marks.rds dropdir/deferred.tsv
	$(pipeR)

######################################################################

## Test Grades to Avenue?
impmakeR += grade
## midterm1.grade.Rout: midtermGrade.R
## midterm2.grade.Rout: midtermGrade.R
midterm%.grade.Rout: midtermGrade.R midterm%.merge.rds gradeFuns.rda
	$(pipeR)

final.grade.Rout: finalGrade.R final.merge.rds
	$(pipeR)

## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=757445

Ignore += *.avenue.csv
## midterm1.avenue.Rout.csv: avenue.R midterm1.avenue.Rout
## midterm2.avenue.Rout.csv: avenue.R midterm2.avenue.Rout
## final.avenue.Rout.csv: avenue.R
impmakeR += avenue
%.avenue.Rout: %.grade.rds avenue.R
	$(pipeR)

## TF is this?? Not working 2026 Mar 11 (Wed)
## https://cap.mcmaster.ca/mcauth/login.jsp?app_id=1505&app_name=Avenue

######################################################################

Sources += poll.mk ## Poll everywhere bonus not used

## Final exam and final grade

## Read and combine different mark sources
combine.Rout: combine.R marks.rds midterm1.merge.rds midterm2.merge.rds final.merge.rds
	$(pipeR)

gradeFuns.Rout: gradeFuns.R
	$(wrapR)

## Final grade: 
## Check weightings, number of assignments, components, etc.
## course.Rout.csv: course.R
course.Rout: course.R gradeFuns.rda combine.rds
	$(pipeR)

## 2021 special-purpose (final grades to Avenue)
## courseAvenue.Rout.csv: courseAvenue.R
courseAvenue.Rout: courseAvenue.R course.rds
	$(pipeR)

######################################################################

## Mosaic

## Go to course through faculty center
## https://mosaic.mcmaster.ca/psp/prcsprd/EMPLOYEE/SA/c/SA_LEARNING_MANAGEMENT.SS_FACULTY.GBL?pslnkid=MCM_WC_FCLT_CNTR&FolderPath=PORTAL_ROOT_OBJECT.MCM_WC_FCLT_CNTR

## CHECK class number (needs to be cribbed from Mosaic and entered here)

## New version 2022 May 02 (Mon); make the file from scratch?
## mosaic_final.Rout.csv: mosaic_final.R
## mosaic_final.Rout.csv: mosaic_final.R
mosaic_final.Rout: mosaic_final.R course.rds
	$(pipeR)

## DNWs available in final.merge.Rout

## Dropping something called mosaic_grade.R from Makefile 2026 Apr 20 (Mon)
## It used to be in the pipe below (instead of _final)

## Upload this .csv to mosaic
## Faculty center, online grading tab

## Copy grades to dropdir for diffing:
grade.update: mosaic_final.Rout.csv
	cp $< dropdir
Ignore += grade.diff

## mv dropdir/mosaic_final.Rout.csv dropdir/mosaic_morning.Rout.csv ##
grade.diff: mosaic_final.Rout.csv dropdir/mosaic_final.Rout.csv
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

Makefile: makestuff/01.stamp
makestuff/%.stamp:
	- $(RM) makestuff/*.stamp
	(cd makestuff && $(MAKE) pull) || git clone --depth 1 $(msrepo)/makestuff
	touch $@

-include makestuff/os.mk

-include makestuff/pipeR.mk
-include makestuff/compare.mk
-include makestuff/mirror.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
