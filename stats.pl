while (<>){
	s/[^[:ascii:]]//g;
	print;
}
