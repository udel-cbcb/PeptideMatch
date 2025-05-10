while($line=<>) {
	if($line=~ /^>/) {
		$def = (split(/\s+/, $line))[0];
		print $def."\n";
	}
	else {
		print $line;
	}
}
