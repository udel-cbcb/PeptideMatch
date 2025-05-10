if(@ARGV != 1) {
	print "Usage: perl getCondenseChildren.pl lineage.txt\n";
	exit 1;
}
#1139427	root {[1, no]}; cellular organisms {[131567, no rank]}; Eukaryota {[2759, superkingdom]}; Opisthokonta {[33154, no rank]}; Metazoa {[33208, kingdom]}; Eumetazoa {[6072, no rank]}; Bilateria {[33213, no rank]}; Coelomata {[33316,

open(LINEAGE, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<LINEAGE>) {
	chomp($line);
	($org, $lineage) =(split(/\t/, $line))[0, 1];
	@rec = split(/\]\}\;/, $lineage);
	$shortLineageStr = "";
	$count = 0;
	$recSize = @rec;
	$parent = $rec[0];
	$parent =~ s/^\s+//;
	$parent =~ s/\s+$//;
	$parent .="]}";
	$child = $rec[1];
	$child =~ s/^\s+//;
	$child =~ s/\s+$//;
	$child .="]}";
	if($parentChild{$parent} !~ /\Q$child\E/) {
		$parentChild{$parent} .= $child."; ";
	}
	$parent = $child;
	for($i=2; $i < $recSize; $i++) {
		($taxonInfo) = (split(/ \{\[/, $rec[$i]))[1];
		($taxId, $rank) = (split(/\, /, $taxonInfo))[0, 1];
		$count++;
		if($rank eq "superkingdom" || $rank eq "kingdom" || $rank eq "phylum" || $rank eq "class" || $rank eq "order" || $rank eq "family" || $rank eq "genus" || $rank eq "species" || $org == $taxId) {
			$child = $rec[$i];
			$child =~ s/^\s+//;
			$child =~ s/\s+$//;
			$child .="]}";
			if($parentChild{$parent} !~ /\Q$child\E/) {
				$parentChild{$parent} .= $child."; ";
			}	
			$parent = $child;
		}
	}
}
close(LINEAGE);

for $parent (sort keys %parentChild) {
	print $parent."\t".$parentChild{$parent}."\n";
}
