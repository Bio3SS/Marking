use strict;
use 5.10.0;

say "OrgDefinedId,M1 bubble Text Grade,End-of-Line Indicator";
while(<>){
	## s/^/"/;
	s/ /X/;
	s/\t/,/;
	s/\t/: /;
	s/\t//g;
	s/$/,#/;
	print;
}

