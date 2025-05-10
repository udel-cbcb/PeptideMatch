if(@ARGV != 2) {
	print "Usage: perl addPrideToIPro.pl pride_uniprotAC_info.txt ipro.txt\n";
	exit 1;
}
#1139427	root {[1, no]}; cellular organisms {[131567, no rank]}; Eukaryota {[2759, superkingdom]}; Opisthokonta {[33154, no rank]}; Metazoa {[33208, kingdom]}; Eumetazoa {[6072, no rank]}; Bilateria {[33213, no rank]}; Coelomata {[33316,

open(PRIDE, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<PRIDE>) {
	chomp($line);
	($uniprot, $pride) =(split(/\s+/, $line))[0, 1];
	$pride{$uniprot} = $pride;
}
close(PRIDE);
open(IPRO, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<IPRO>) {
	#>A0A171 A0A171_PYRHR^|^^|^Glutamate synthase small subunit-like protein 1^|^^|^^|^Pyrococcus horikoshii^|^53953^|^Arch/Euryar^|^28890
	if($line =~ /^>/) {
		chomp($line);
                @rec = split(/\^\|\^/, $line);
		$ac_id = $rec[0];
		($ac) = (split(/\s+/, $ac_id))[0];	
		if(@rec == 7 && $line !~ /\^$/) {
			if($pride{$ac}) {
                		print $line."^|^^|^^|^^|^^|^".$pride{$ac}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^^|^Z\n";
			}
		}
		elsif(@rec == 8 && $line !~ /\^$/) {
			if($pride{$ac}) {
                		print $line."^|^^|^^|^^|^".$pride{$ac}."\n";
			}
			else {
				print $line."^|^^|^^|^^|^Z\n";
			}
		}	
		elsif(@rec == 9 && $line !~ /\^$/) {
			if($pride{$ac}) {
                		print $line."^|^^|^^|^".$pride{$ac}."\n";
			}
			else {
				print $line."^|^^|^^|^Z\n";
			}
		}	
		elsif(@rec == 10 && $line !~ /\^$/) {
			if($pride{$ac}) {
                		print $line."^|^^|^".$pride{$ac}."\n";
			}
			else {
				print $line."^|^^|^Z\n";
			}
		}
		else {
			if($pride{$ac}) {
                		print $line."^|^".$pride{$ac}."\n";
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
