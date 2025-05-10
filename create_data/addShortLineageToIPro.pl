if(@ARGV != 2) {
	print "Usage: perl addShortLineageToIPro.pl shortLineage.txt ipro.txt\n";
	exit 1;
}
#1139427	root {[1, no]}; cellular organisms {[131567, no rank]}; Eukaryota {[2759, superkingdom]}; Opisthokonta {[33154, no rank]}; Metazoa {[33208, kingdom]}; Eumetazoa {[6072, no rank]}; Bilateria {[33213, no rank]}; Coelomata {[33316,

open(LINEAGE, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<LINEAGE>) {
	chomp($line);
	($org, $lineage) =(split(/\t/, $line))[0, 1];
	$orgLineage{$org} = $lineage;	
}
close(LINEAGE);
open(IPRO, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<IPRO>) {
	#>A0A171 A0A171_PYRHR^|^^|^Glutamate synthase small subunit-like protein 1^|^^|^^|^Pyrococcus horikoshii^|^53953^|^Arch/Euryar^|^28890
	if($line =~ /^>/) {
		chomp($line);
                @rec = split(/\^\|\^/, $line);
		$taxonId = $rec[6];
		if(@rec == 7 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^^|^^|^^|^^|^^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^^|^^|^^|^^|^1, -1, ".$taxonId."\n";
			}
		}
		elsif(@rec == 8 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^^|^^|^^|^^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^^|^^|^^|^1, -1, ".$taxonId."\n";
			}
		}	
		elsif(@rec == 9 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^^|^^|^^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^^|^^|^1, -1, ".$taxonId."\n";
			}
		}
		elsif(@rec == 10 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^^|^^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^^|^1, -1, ".$taxonId."\n";
			}
		}
		elsif(@rec == 11 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^1, -1, ".$taxonId."\n";
			}
		}
		elsif(@rec == 12 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^^|^1, -1, ".$taxonId."\n";
			}
		}
		elsif(@rec == 13 && $line !~ /\^$/) {
			if($orgLineage{$taxonId}) {
                		print $line."^|^^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^^|^1, -1, ".$taxonId."\n";
			}
		}
		else {
			if($orgLineage{$taxonId}) {
                		print $line."^|^".$orgLineage{$taxonId}."\n";
			}
			else {
				print $line."^|^1, -1, ".$taxonId."\n";
			}
		}
	}
	else {
		print $line; 
	}
}
close(IPRO);
