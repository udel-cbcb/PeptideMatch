if(@ARGV != 2) {
	print "Usage: perl addUniRef100ToIPro.pl UniRef100.ac ipro.txt\n";
	exit 1;
}
#UniRef100_Q6GZX4

open(UNIREF100, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<UNIREF100>) {
	chomp($line);
	($uniref100) =(split(/\_/, $line))[1];
	$uniref100RP{$uniref100} = $line;
}
close(UNIREF100);
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
		if(@rec == 7 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^^|^^|^^|^^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^^|^^|^^|^^|^^|^^|^\n";
			}
		}
		elsif(@rec == 8 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^^|^^|^^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^^|^^|^^|^^|^^|^\n";
			}
		}	
		elsif(@rec == 9 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^^|^^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^^|^^|^^|^^|^\n";
			}
		}
		elsif(@rec == 10 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^^|^^|^^|^\n";
			}
		}
		elsif(@rec == 11 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^^|^^|^\n";
			}
		}
		elsif(@rec == 12 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^^|^\n";
			}
		}
		elsif(@rec == 13 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^^|^\n";
			}
		}
		elsif(@rec == 14 && $line !~ /\^$/) {
			if($uniref100RP{$ac}) {
                		print  $line."^|^^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^^|^\n";
			}
		}
		else {
			if($uniref100RP{$ac}) {
                		print  $line."^|^".$uniref100RP{$ac}."\n";
			}
			else {
				print  $line."^|^\n";
			}
		}
	}
	else {
		print  $line; 
	}
}
close(IPRO);
