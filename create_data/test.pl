while($line=<>) {
	print $line;	
	chomp($line);
	($iedb, $gi) = (split(/","/, $line))[0, 5];
	$iedb =~ s/\"//g;
	if($gi) {
		print $gi."\n";
		#if($gi !~ m/(\d+)/ && $gi !~ m/^(IP|SRC)/ && $iedb =~ /(\d+)/) {
		if($gi !~ /^(\d+)$/) {
			print "UniProtAC: ".$gi."\t".$iedb."\n";
		}
	}
}
