if(@ARGV != 1) {
	print "Usage: perl getShortLineageo.pl lineage.txt\n";
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
	foreach(@rec) {
		($taxonInfo) = (split(/ \{\[/, $_))[1];
		($taxId, $rank) = (split(/\, /, $taxonInfo))[0, 1];
		$count++;
		if($count <=2) {
			$shortLineageStr .= $taxId.", ";
		}
		else {
			if($rank eq "superkingdom" || $rank eq "kingdom" || $rank eq "phylum" || $rank eq "class" || $rank eq "order" || $rank eq "family" || $rank eq "genus" || $rank eq "species") {
				$shortLineageStr .= $taxId.", ";
			}
			else {
				if($org == $taxId ) {
					$shortLineageStr .= $org.", ";
				}
			}	
		}
	}
	#$shortLineageStr = substr($shortLineageStr, 0, rindex($shortLineageStr, ", ")-2);
	$shortLineageStr =~ s/, $//; 
	print $org."\t".$shortLineageStr."\n";	
}
close(LINEAGE);
