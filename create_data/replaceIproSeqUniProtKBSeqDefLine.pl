if(@ARGV != 2) {
	print "perl replaceIproSeqUniProtKBSeqDefLine.pl seqDefLine.txt ipro.seq.uniprotkb.txt\n";
	exit 1; 
}

open(SEQDEF, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<SEQDEF>) {
	($ac) = (split(/\s+/, $line))[0];
	$seqDef{$ac} = $line;
}
close(SEQDEF); 
open(SEQ, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<SEQ>) {
	if($line =~ /^>/) {
		($ac) = (split(/\s+/, $line))[0];
		if($ac =~ /-/) {
			$isoAC = $ac;
			($ac) = (split(/-/, $isoAC))[0];
			if($seqDef{$ac}) {
				$defline = $seqDef{$ac};
				$defline =~ s/^$ac /$isoAC /;	
				print $defline;
			}
			else {
				print $line;
			}
		}
		else {
			if($seqDef{$ac}) {
				print $seqDef{$ac};
			}
			else {
				print $line;
			}
		}
	}
	else {
		print $line;
	}
}
close(SEQ);
