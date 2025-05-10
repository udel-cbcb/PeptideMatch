#!/usr/bin/perl

if(@ARGV != 2) {
        print "perl getUniProtACToPride.pl sprot.dat trembl.dat\n";
        exit 1;
}

my $firstAC = "";
my $pmidScore = 0;
my $pdbScore = 0;
my $spScore = 0; 
my $ignorePMID;
my %pmids = ();
my %pdbs = ();
my %taxIdPmidHash = ();
my %taxIdPdbHash = ();
my %taxIdSpHash = ();
my %taxIdEntryHash = ();
my %taxIdEntryScoreSumHash = ();
my %taxIdHash = ();
my %refp = ();
my %cpa = ();
my %nameToTaxon = ();

#print "Starting reading Swiss-Prot data\n";
getOrgNameAndTaxonId($ARGV[0]);
#print "Finish reading Swiss-Prot data\n";

#print "Starting reading Swiss-Prot data\n";
getOrgNameAndTaxonId($ARGV[1]);
#print "Finish reading Swiss-Prot data\n";

for $name (sort keys %nameToTaxon) {
	print $name."\t".$nameToTaxon{$name}."\n";
}
sub getOrgNameAndTaxonId {
	my ($dataFile) =@_;
	open(DATA, "<", $dataFile) or die "Can't open $dataFile\n";
	while($line=<DATA>){
		chomp($line);
        	if ($line=~ /^ID/) {
			$start = 1;
			$taxId = "";
			$scientificName = "";
		}
		elsif ($line=~ /^AC   /) {
                	$ac=(split /\s+/,$line)[1]; $ac=~s/\;//;
                	if($firstAC eq "") {
                        	$firstAC = $ac;
                	}  
		}              #
		#NCBI_TaxID=115547;
		elsif($line =~ /^DR   PRIDE\;/) {
                	$line =~ s/^DR\s+PRIDE\;//;
                	$prideId = (split(/\;/, $line))[0];
        	}

        	elsif ($line =~ /^\/\/$/) {
			$start = 0;
			if($prideId) {
				print ">".$firstAC."\t".$prideId."\n";
			}	
			$firstAC = "";
			$prideId = "";
			#$taxToName{$taxId} = $scientificName;	
        	}
	}
	close(DATA);
}
