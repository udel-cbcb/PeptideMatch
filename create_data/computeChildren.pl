if(@ARGV != 4) {
	print "Usage: perl computeChildren.pl iprotaxid.txt id2name.txt id2parent.txt out.txt\n";
	exit 1;
}
my %nameHash = ();
my %allNamesHash = ();
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
#	print $key."|".$nameHash{$key}."\n";
}
print "ipro size: " . (keys %ipro)."\n";
$childrenHash{"root {[1, no]}"} = "Others {[0, no rank]}; ";
for $org (keys %ipro) {
	#print $org."|".$nameHash{$org}."|\n";
	$count++;
	#print "count: ".$count."\n";
	if($iproName{$org}) {
		$children = $iproName{$org}." {[".$org.", ".$orgType{$org}."]}";	
	}
	else {
		$children = $nameHash{$org}." {[".$org.", ".$orgType{$org}."]}";	
	}
	#if(index($chidrenHash{$org},  $chidren)== -1) {
	#	$chidrenHash{$org} .= $chidren;
	#}	
	#print $lineage."??\n";
	if($parentHash{$org}) {
		$pid = $parentHash{$org};
		while($pid !=1) {
			if($orgType{$pid}) {
				if($iproName{$pid}) {
					$parent = $iproName{$pid}." {[".$pid.", ".$orgType{$pid}."]}";	
				}
				else {
					$parent = $nameHash{$pid}." {[".$pid.", ".$orgType{$pid}."]}";	
				}
			}
			else {
				if($iproName{$pid}) {
					$parent = $iproName{$pid}." {[".$pid.", no rank]}";	
				}
				else {
					$parent = $nameHash{$pid}." {[".$pid.", no rank]}";	
				}
			}
			if(index($childrenHash{$parent},  $children)== -1) {
				$childrenHash{$parent} .= $children."; ";
			}
			$children = $parent;	
			$pid = $parentHash{$pid};	
		}
		if(index($childrenHash{"root {[1, no]}"}, $children)== -1) {
			print "root {[1, no]}\t|".$children."\n";
			$childrenHash{"root {[1, no]}"} .= $children."; ";
		}	
	}
	else {
		#print "Others: $org\n";
		if($orgType{$org}) {
			if($iproName{$org}) {
				$childrenHash{"Others {[0, no rank]}"} .= $iproName{$org}." {[".$org.", ".$orgType{$org}."]}; ";	
			}
			else {
				$childrenHash{"Others {[0, no rank]}"} .= $nameHash{$org}." {[".$org.", ".$orgType{$org}."]}; ";	
			}
		}
		else {
			if($iproName{$org}) {
				$childrenHash{"Others {[0, no rank]}"} .= $iproName{$org}." {[".$org.", no rank]}; ";	
			}
			else {
				$childrenHash{"Others {[0, no rank]}"} .= $nameHash{$org}." {[".$org.", no rank]}; ";	
			}
		}
	}
}
open(OUT, ">", $ARGV[3]) or die "Can't open $ARGV[3]\n";
for $org (sort keys %childrenHash) {
	$children = $childrenHash{$org};
	print OUT $org."\t".$children."\n";
}
close(OUT);

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
