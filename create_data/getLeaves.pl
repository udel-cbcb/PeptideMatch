if(@ARGV != 2) {
	print "Usage: perl getLeaves.pl nonLeaves.txt orgs.txt\n";
	exit 1;
}
open(NON, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<NON>) {
	chomp($line);
	$nonLeaves{$line} = 1;	
}
close(NON);

open(ORGS, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<ORGS>) {
	chomp($line);
	if(!$nonLeaves{$line}) {
		print $line."\n";
	}
}
close(ORGS);
