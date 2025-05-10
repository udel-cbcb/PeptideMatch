if(@ARGV != 1) {
        print "Usage: perl convertIproFastatoTab.pl ipro.txt\n";
}
open(IPRO, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<IPRO>) {
        chomp($line);
        $line =~ s/\s+$//;
         if($line =~ /^>/) {
                @rec = split(/\^\|\^/, $line);
		print @rec."\n";
	}
}
close(IRPO);
