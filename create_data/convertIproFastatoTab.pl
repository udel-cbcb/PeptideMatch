if(@ARGV != 1) {
	print "Usage: perl convertIproFastatoTab.pl ipro.txt\n";	
}
print "id\tproteinID\tproteinName\torganismName\torganismID\ttaxongroupName\ttaxongroupID\tnist\tpeptideAtlas\tpride\tiedb\tfullLineage\tshortLineage\tuniref100\tisSP\tisIsoform\tseq\n";
open(IPRO, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<IPRO>) {
	chomp($line);
	$isSP = "false";
	$isIsoform = "false";
	$line =~ s/\s+$//;
	if($line =~ /^>/) {
		$line =~ s/^>//;
		($ac_id, $proteinName, $organismName, $organismID, $taxongroupName, $taxongroupID, $nist, $atlas, $pride, $iedb, $fullLineage, $shortLineage, $uniref100)  = (split(/\^\|\^/, $line))[0, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
		($ac, $proteinID) = (split(/\s+/, $ac_id))[0, 1];
		#print $ac."||||||".$proteinID."?\n";
		($id0, $id1) = (split(/_/, $proteinID))[0,1];
		if(length($id0) < 6) {
			#print $id0."\n";
			$isSP = "true";
		}
		if($ac =~ /-/) {
			$isIsoform = "true";
		}
		print $ac."\t".$proteinID."\t".$proteinName."\t".$organismName."\t".$organismID."\t";
		if($taxongroupName && $taxongroupName !~ /Z/) {
			print $taxongroupName."\t";
		}
		else {
			print "other\t";
		}
		if($taxongroupID && $taxongroupID !~ /Z/) {
			print $taxongroupID."\t";
		}
		else {
			print "\t";
		}
		if($nist && $nist !~ /Z/) {
			print $nist."\t";
		}
		else {
			print "\t";
		}
		if($peptideAtlas && $peptideAtlas !~ /Z/) {
			print $peptideAtlas."\t";
		}
		else {
			print "\t";
		}
		if($pride && $pride !~ /Z/) {
			print $pride."\t";
		}
		else {
			print "\t";
		}
		if($iedb && $iedb !~ /Z/) {
			print $iedb."\t";
		}
		else {
			print "\t";
		}
		print $fullLineage."\t".$shortLineage."\t".$uniref100."\t".$isSP."\t".$isIsoform."\t";	
	}
	else {
		#print $line."\t";
		#$seqIndex = threegramtokenizer($line);
		$seqIndex = join(" ",split(//,$line));
		$lToiSeqIndex = $seqIndex;
		$lToiSeqIndex =~ s/L/I/g;
		print "NT ".$seqIndex." CT\n";
	}
}
close(IPRO);

sub threegramtokenizer() {
	($line) = @_;
	$str = "";
	@rec = split(//, $line);
        for($i=0; $i < @rec-2; $i++) {
                for($j=0; $j < 3; $j++) {
                        $str .= $rec[$i+$j];
                }
                $str .= " ";
        }
	return $str;
}
