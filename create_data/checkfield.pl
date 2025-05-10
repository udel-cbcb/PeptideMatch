if(@ARGV != 2) {
	print "Usage: perl checkField.pl ipro.txt count\n";	
}
open(IPRO, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<IPRO>) {
	chomp($line);
	 if($line =~ /^>/) {
		@rec = split(/\^\|\^/, $line);
		if(@rec < $ARGV[1]) {
			print $line."\n";
		}
	}
}
close(IPRO);
