if(@ARGV != 5) {
	print "Usage: perl computeLineage.pl iprotaxid.txt id2name.txt id2parent.txt lineage.txt name.txt\n";
	exit 1;
}
my %nameHash = ();
open(IPRO, $ARGV[0]) or die "can't open $ARGV[0]\n";
while($line=<IPRO>) {
	chomp($line);
	($id, $name) = (split(/\t/, $line));
	$ipro{$id} = 1;
	$iproName{$id} = $name;
}
close(IPRO);

open(NAME, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<NAME>) {
	chomp($line);
	@rec = split(/\s+/, $line);
	$recSize = @rec;
	$name = "";
	for($i=1; $i <$recSize; $i++) {
		$name .= $rec[$i]." ";	
	} 
	$name =~ s/\s+$//;
	$nameHash{$rec[0]} = $name;	
	if($iproName{$rec[0]}) {
                $allNamesHash{$rec[0]} = $iproName{$rec[0]};
        }
        else {
                $allNamesHash{$rec[0]} = $name;
        }
}	
close(NAME);

open(PARENT, $ARGV[2]) or die "Can't open $ARGV[2]\n";
while($line=<PARENT>) {
	chomp($line);
	@rec = split(/\s+/, $line);
	$recSize = @rec;
	$name = "";
	for($i=2; $i <$recSize; $i++) {
		$name .= $rec[$i]." ";	
	}
	$name =~ s/\s+$//;
	$parentHash{$rec[0]} = $rec[1];
	$orgType{$rec[0]} = $name;
	if($name =~ /species/) {
		$orgHash{$rec[0]} = 1;
		#if($rec[0] =~ /99287/) {
		#	print "1: ".$line."\n";
		#}
	}
	if($orgType{$parentHash{$rec[0]}} =~ /species/) {	 
		$hasParentSpecies{$rec[0]} = 1;
		#if($rec[0] =~ /99287/) {
		#	print "2: ".$line."\n";
		#}
	}
	$isParent{$rec[1]} = 1;
		
}
close(PARENT);
$count = 0;
print "name hash: ".(keys %nameHash)."\n";
for $key (keys %nameHash) {
	print $key."|".$nameHash{$key}."\n";
}
print "ipro size: " . (keys %ipro)."\n";
open(OUT, ">", $ARGV[3]) or die "Can't open $ARGV[3]\n";
for $org (keys %ipro) {
	print $org."|".$nameHash{$org}."|\n";
	$count++;
	print "count: ".$count."\n";
	$lineage = $nameHash{$org}." {[".$org.", ".$orgType{$org}."]}";	
	#print $lineage."??\n";
	if($parentHash{$org}) {
		$pid = $parentHash{$org};
		while($pid != 1) {
			if($iproName{$pid}) {
				$lineage = $iproName{$pid}." {[".$pid.", ".$orgType{$pid}."]}; ".$lineage;
			}
			else {
				$lineage = $nameHash{$pid}." {[".$pid.", ".$orgType{$pid}."]}; ".$lineage;
			}
			$pid = $parentHash{$pid};	
		}
		if($iproName{$pid}) {
			$lineage = $iproName{$pid}." {[".$pid.", ".$orgType{$pid}."]}; ".$lineage;	
		}
		else {
			$lineage = $nameHash{$pid}." {[".$pid.", ".$orgType{$pid}."]}; ".$lineage;	
		}
		print OUT $org."\t".$lineage."; \n";
	}
	else {
		if($orgType{$org}) {
			if($iproName{$org}) {
				$lineage = "root {[1, no]}; Others {[0, no rank]}; ".$iproName{$org}." {[".$org.", ".$orgType{$org}."]}";	
			}
			else {
				$lineage = "root {[1, no]}; Others {[0, no rank]}; ".$nameHash{$org}." {[".$org.", ".$orgType{$org}."]}";	
			}
		}
		else {
			if($iproName{$org}) {
				$lineage = "root {[1, no]}; Others {[0, no rank]}; ".$iproName{$org}." {[".$org.", no rank]}";	
			}
			else {
				$lineage = "root {[1, no]}; Others {[0, no rank]}; ".$nameHash{$org}." {[".$org.", no rank]}";	
			}
		}
		print OUT $org."\t".$lineage."; \n";
	}
}
close(OUT);

open(NAME, ">", $ARGV[4]) or die "Can't open $ARGV[4]\n";
for $taxon (sort keys %allNamesHash) {
	print NAME $taxon."\t".$allNamesHash{$taxon}."\n";
}
close(NAME); 
sub hasParentSpeciesOrSubspecies () {
	$parentHashRef = shift;
	$orgTypeHashRef = shift;
	$org = shift;
	#print "I am here\n";
	my %parentHash =%$parentHashRef;
	my %orgTypeHash = %$orgTypeHashRef;
	#print "parentHash size: ".(keys %parentHash)."\n";
	#print "orgTypeHash size: ".(keys %parentHash)."\n";
	$parent = $parentHash{$org};
	while($parent != 1) {
		if($orgTypeHash{$parent} =~ /species/) {
			#print $org."\t?".$parent."\t".$orgTypeHash{$parent}"\n";
			return 1;
		}
		#print $org."\t?".$parent."\t".$orgTypeHash{$parent}."\n";
		$parent = $parentHash{$parent};
	}
	return 0;				
}
