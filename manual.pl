use 5.10.0;
use strict;

if(@ARGV){while(<>){
	chomp;
	s/ /\t/;
	s/ /\t/;
	s/ //g;
	my ($num, $ver, $ans) = split;
	$ans = uc($ans);
	$ans =~ s/./\t$&/g;
	say "$num\t$ver$ans";
}}
