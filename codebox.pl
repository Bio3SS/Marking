use strict;
use 5.10.0;

my %id;

while(<>){
	chomp;
	next unless /From/;
	next if /Resent/;
	s/.*<//;
	s/>.*//;
	next unless /mcmaster.ca/;
	s/@.*//;
	next if /dushoff/i;
	$id{$_} = 1;
}

say join "\n", keys %id;
