if(@ARGV != 3) {
	print "Usage: perl getUniProtACToIedbMap.pl idmapping.txt iedb.txt UniProtACToIeDB.txt\n";
	exit 1;
}
#open(IDMAP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
open(IDMAP, "gunzip -c $ARGV[0]|") or die "Can't open $ARGV[0]\n";
while($line=<IDMAP>) {
	chomp($line);
	($ac, $type, $id) = (split(/\t/, $line))[0, 1, 2];
	if($type =~ /GI/) {
		if(!$giToAC{$id}) {
			#print $line."\n";
			$giToAC{$id} = $ac;
		}	
	}
	if($type =~ /RefSeq/) {
		if(!$refseqToAC{$id}) {
			$refseqToAC{$refseq} = $ac;
		}
	}
}
close(IDMAP);
open(IEDB, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<IEDB>) {
	chomp($line);
	($iedb, $ac) = (split(/\t/, $line))[0, 1];
	$iedb_uri =  "http://www.iedb.org/epitope/";
	$uniprot_uri ="http://www.uniprot.org/uniprot/";
	$refseq_uri = "http://www.ncbi.nlm.nih.gov/protein/";
	$iedb =~ s/$iedb_uri//;	
	if($ac) {
		if($ac =~ /uniprot/) {
			$ac =~ s/$uniprot_uri//;		
			$acToIedb{">".$ac."\t".$iedb."\t".$ac} = 1;
		}
		elsif($ac =~ /ncbi/) {
			$ac =~ s/$refseq_uri//;
			if($ac =~ /^(\d+)$/) {
				if($giToAC{$ac}) {
					$acToIedb{">".$giToAC{$ac}."\t".$iedb."\t".$ac} = 1;
				}
			}
			else {
				if($refseqToAC{$ac}) {
					$acToIedb{">".$refseqToAC{$ac}."\t".$iedb."\t".$ac} = 1;
				}
			}
		}
	}
}
close(IEDB);
open(OUT, ">", $ARGV[2]) or die "Can't open $ARGV[2]\n";
for $key (sort keys %acToIedb) {
	print OUT $key."\n";
}
close(OUT);
