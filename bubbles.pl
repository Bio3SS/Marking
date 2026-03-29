use strict;
use 5.10.0;

my $test=$ARGV[0];
$test =~ s/\..*//;

say "OrgDefinedId,$test bubble Text Grade,End-of-Line Indicator";
while(<>){
	## s/^/"/;
	s/ /X/;
	s/\t/,/;
	s/\t/: /;
	s/\t//g;
	s/$/,#/;
	print;
}

