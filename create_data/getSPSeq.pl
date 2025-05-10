#>I1WXP1 I1WXP1_9EURY^|^^

while($line=<>) {
	if($line =~ /^>/) {
		($id_ac) = (split(/\^\|\^/, $line))[0];
		#print $id_ac."\n";
		($id) = (split(/\s+/, $id_ac))[1];
		($sptr) = (split(/_/, $id))[0];
		#print $sptr."\n";
		if(length($sptr) < 6) {
			print $line;
			$sp = 1;
		}
		else {
			$sp = 0;
		}
	}
	else {
		if($sp) {
			print $line;
		}
	}
}
