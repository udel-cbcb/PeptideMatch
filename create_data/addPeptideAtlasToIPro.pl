if(@ARGV != 2) {
	print "Usage: perl addPeptideAtlasToIPro.pl peptideatlas_uniprotAC_info.txt ipro.txt\n";
	exit 1;
}
#1139427	root {[1, no]}; cellular organisms {[131567, no rank]}; Eukaryota {[2759, superkingdom]}; Opisthokonta {[33154, no rank]}; Metazoa {[33208, kingdom]}; Eumetazoa {[6072, no rank]}; Bilateria {[33213, no rank]}; Coelomata {[33316,

open(ATLAS, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<ATLAS>) {
	chomp($line);
	($uniprot, $peptideAtlas) =(split(/\s+/, $line))[0, 1];
	$atlas{$uniprot} = $peptideAtlas;
}
close(ATLAS);
open(IPRO, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<IPRO>) {
	#>A0A171 A0A171_PYRHR^|^^|^Glutamate synthase small subunit-like protein 1^|^^|^^|^Pyrococcus horikoshii^|^53953^|^Arch/Euryar^|^28890
	if($line =~ /^>/) {
		chomp($line);
                @rec = split(/\^\|\^/, $line);
		$ac_id = $rec[0];
		($ac) = (split(/\s+/, $ac_id))[0];	
		if(@rec == 7 && $line !~ /\^$/) {
			if($atlas{$ac}) {
                		print $line."^|^^|^^|^^|^".$atlas{$ac}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^Z\n";
			}
		}
		elsif(@rec == 8 && $line !~ /\^$/) {
			if($atlas{$ac}) {
                		print $line."^|^^|^^|^".$atlas{$ac}."\n";
			}
			else {
				print $line."^|^^|^^|^Z\n";
			}
		}	
		elsif(@rec == 9 && $line !~ /\^$/) {
			if($atlas{$ac}) {
                		print $line."^|^^|^".$atlas{$ac}."\n";
			}
			else {
				print $line."^|^^|^Z\n";
			}
		}	
		else {
			if($atlas{$ac}) {
                		print $line."^|^".$atlas{$ac}."\n";
			}
			else {
				print $line."^|^Z\n";
			}
		}
	}
	else {
		print $line; 
	}
}
close(IPRO);
