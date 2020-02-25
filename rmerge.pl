use 5.10.0;
use strict;

my %idlist;
while (<>){
	chomp;
	next if /^$/;
	my ($id, $scores) = /^([ 0-9]*)\t([*0-5A-E \t-]*)\s*$/ or
		die "Unparsed line $_";
	say "#$id\t$scores" unless defined $idlist{$id};
	$idlist{$id} = 0;
}

