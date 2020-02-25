use 5.10.0;
use strict;

say "Version,Question,A,B,C,D,E";
my $ver=0;
while(<>){
	chomp;
	next if /Question/;
	if (/Version,([1-9])/){
		$ver = $1;
	} else {
		say "$ver,$_";
	}
}
