#TaxId=53953
#TaxGrp=Arch/Euryar
#TaxGrpId=28890

#%taxIdToTaxGroupHash = ();
#%taxIdToTaxGroupIdHash = ();
%taxMap = ();
open (IN,"NF.tbl.intermediate");
while($line=<IN>)
{
	chomp($line);
	if($line =~ /^>/) {
		$taxId = "";
		$taxGroup = "";
		$taxGroupId = "";
	}
	if($line =~ /^Organism\=/) {
		$organismName = (split(/\=/, $line))[1];
		chomp($organismName);
		#print $organismName."\n";
	} 
	if($line =~ /^TaxId\=/) {
		$taxId = (split(/\=/, $line))[1];
		chomp($taxId);
	} 
	if($line =~ /^TaxGrp\=/) {
		$taxGroup = (split(/\=/, $line))[1];
		chomp($taxGroup);
	} 
	if($line =~ /^TaxGrpId\=/) {
		$taxGroupId = (split(/\=/, $line))[1];
		chomp($taxGroupId);
	} 
	if($line =~ /^Lineage\=/) {
		$lineage = (split(/\=/, $line))[1];
		chomp($lineage);
	} 
	if($line =~ /^Seq\=/) {
		if($taxId ne "") {
			#if($taxId eq "Virus") {
				#print $taxId."\n";
			#}
                	#$taxIdToTaxGroupHash{$taxId} = $taxGroup;
                	#$taxIdToTaxGroupIdHash{$taxId} = $taxGroupId;
			#print $taxId."|".$taxGroup."|".$taxGroupId."|\n";
			if(!$taxGroup) {
				$taxNoGroup{$taxId} = 1;
				 if($lineage =~ /^Bacteria\;/) {
                                	$taxGroup = "Bac/..";
					$taxGroupId = 2157;
                        	}
                        	if($lineage =~ /^Archaea\;/) {
                                	$taxGroup = "Archaea/..";
					$taxGroupId = 2157;
                        	}
                        	elsif($lineage =~ /^Eukaryota;/) {
                                	$taxGroup = "Euk/..";
					$taxGroupId = 2759;
                        	}
				$taxMapWithName{$taxId} = $taxId."\t".$organismName."\t".$taxGroupId."\t".$taxGroup;
				$taxMap{$taxId} = $taxId."\t".$taxGroup."\t".$taxGroupId;
			}
			else {
				$taxMapWithName{$taxId} = $taxId."\t".$organismName."\t".$taxGroupId."\t".$taxGroup;
				$taxMap{$taxId} = $taxId."\t".$taxGroup."\t".$taxGroupId;
			}
		}
	}               
}
close(IN);
open(TAXGNAME, ">", "taxToTaxGroupWithName.txt") or die;
for my $k (sort %taxMapWithName) {
	if($k ne "") {	
		$mapping = $taxMapWithName{$k};
		chomp($mapping);
		if($mapping) {
       			print TAXGNAME $mapping."\n";
		}
	}
}
close(TAXGNAME);

open(TAXG, ">", "taxToTaxGroup.txt") or die;
for my $k (sort %taxMapWithName) {
	if($k ne "") {	
		$mapping = $taxMap{$k};
		chomp($mapping);
		if($mapping) {
       			print TAXG $mapping."\n";
		}
	}
}
close(TAXG);
for my $k (sort keys %taxNoGroup) {
        print $k."\n";
}

