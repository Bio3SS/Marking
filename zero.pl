use strict;
use 5.10.0;

while(<>){
	chomp;
	s///;
	s/^\t/0\t/;
	while(s/\t\t/\t0\t/){};
	s/\t$/\t0/;
	say;
}
