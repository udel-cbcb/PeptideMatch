if(@ARGV != 2) {
	print "Usage: perl addUniRefACsToIPro.pl UniNREF.tbl.link ipro.txt\n";
	exit 1;
}
#UniRef100_Q6GZX4

open(UNIREF, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<UNIREF>) {
	chomp($line);
	($ac, $uniref100, $uniref90, $uniref50) =(split(/\t/, $line))[0, 1, 2, 3];
	$unirefACs{$ac} = $uniref100.",".$uniref90.",".$uniref50;
}
close(UNIREF);
$count = 0;
open(IPRO, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<IPRO>) {
	if($line =~ /^>/) {
		$count++;
		chomp($line);
		 @rec = split(/\^\|\^/, $line);
                $ac_id = $rec[0];
                ($ac) = (split(/\s+/, $ac_id))[0];
		#print $ac."\n";
		$ac =~ s/^>//;
		if($unirefACs{$ac}) {
                		print  $line."^|^".$unirefACs{$ac}."\n";
		}
		else {
			print  $line."^|^\n";
		}
	}
	else {
		print  $line; 
	}
}
close(IPRO);
