#TaxId=53953
#TaxGrp=Arch/Euryar
#TaxGrpId=28890

#%taxIdToTaxGroupHash = ();
#%taxIdToTaxGroupIdHash = ();
%taxMap = ();
open (IN,"pir_search_fields.dat");
while($line=<IN>)
{
	chomp($line);
	if($line =~ /^>/) {
		#print $line."\n";	
		if($ac) {
			$seqDefLine{$ac} = $ac." ".$id."^|^".$piId."^|^".$proteinName."^|^".$sfId."^|^".$sfText."^|^".$organismName."^|^".$taxId."^|^".$taxGroup."^|^".$taxGroupId."\n";
		
			#print $seqDefLine{$ac};
		}
		$ac = $line;
		$id = "";
		$piId = "";
		$proteinName = "";
		$sfId = "";
		$sfText = "";
		$organismName = "";	
		$taxId = "";
		$taxGroup = "";
		$taxGroupId = "";
	}
	if($line =~ /^SWIDS\=/) {
		$id = $line;
		$id =~ s/^SWIDS\=//;
		$id =~ s/\s+$//;
	} 
	if($line =~ /^TRIDS\=/) {
		$id = $line;
		$id =~ s/^TRIDS\=//;
		$id =~ s/\s+$//;
	} 
	if($line =~ /^PIIDS\=/) {
		$piids = $line;
		$piids =~ s/^PIIDS\=//;
		$piids =~ s/\s+$//;
	} 
	if($line =~ /^PRONAME_TXT\=/) {
		$proteinName1 = $line;
		$proteinName1 =~ s/^PRONAME_TXT\=//;
		$proteinName = (split(/;/, $proteinName1))[0];
		$proteinName =~ s/\s+$//;
	} 
	if($line =~ /^ORGNAME_TXT\=/) {
		$organismName1 = $line;
		$organismName1 =~ s/^ORGNAME_TXT\=//;
		$organismName = (split(/;/, $organismName1))[0];
		$organismName =~ s/\s+$//;
	} 
	if($line =~ /^SUPFAM\=/) {
		$sfId = $line;
		$sfId =~ s/^SUPFAM\=//;
		$sfId =~ s/\s+$//;
	} 
	if($line =~ /^SUPFAM_TXT\=/) {
		$sfText = $line;
		$sfText =~ s/^SUPFAM_TXT\=//;
		$sfText =~ s/\s+$//;
	} 
	if($line =~ /^TAXID\=/) {
		$taxId = $line;
		$taxId =~ s/^TAXID\=//;
		$taxId =~ s/\s+$//;
	} 
	if($line =~ /^TAXGRP\=/) {
		$taxGroup = $line;
		$taxGroup=~ s/^TAXGRP\=//;
		$taxGroup =~ s/\s+$//;
	} 
	if($line =~ /^TAXGRPID\=/) {
		$taxGroupId = $line;
		$taxGroupId=~ s/^TAXGRPID\=//;
		$taxGroupId =~ s/\s+$//;
	} 
}
close(IN);
if($ac) {
	$seqDefLine{$ac} = $ac." ".$id."^|^".$piId."^|^".$proteinName."^|^".$sfId."^|^".$sfText."^|^".$organismName."^|^".$taxId."^|^".$taxGroup."^|^".$taxGroupId."\n";
}

open(SEQDEFLINE, ">", "seqDefLine.txt") or die;
for my $k (sort %seqDefLine) {
	print SEQDEFLINE $seqDefLine{$k};
}
close(SEQDEFLINE);
