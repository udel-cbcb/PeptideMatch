use strict;
#use warnings;
use LWP::UserAgent;
use Getopt::Long;

my $base = 'http://alanine.bioinformatics.udel.edu/peptidematch_new/webservices/peptidematch_rest';

my ($queryFile, $organismFile, $format);

if(@ARGV < 2 or !GetOptions('queryFile=s' => \$queryFile, 'organismFile=s' => \$organismFile, 'format=s' => \$format)) {
	usage();
	exit 1;
}

sub usage {
	print "Unknown option: @_\n" if (@_);
	print "usage: program [--queryFile] path_to_queryFile [--organmsimFile] path_to_organimsFile [--format] tab|xls|fasta|xml\n";	
}

if(!$format) {
	$format ='tab';
}

my $query = "";
my $organism = "";

open(QUERY, $queryFile) or die "Can't open $queryFile\n";
while(my $line=<QUERY>) {
	$query .= $line.",";	
}
close(QUERY);
$query =~ s/\,$//;

open(ORGANISM, $organismFile) or die "Can't open $organismFile\n";
while(my $line=<ORGANISM>) {
	$organism .= $line.",";	
}
$organism =~ s/\,$//;
close(ORGANISM);

my $params = {
  format => $format,
  query => $query,
  organism => $organism 
};


my $agent = LWP::UserAgent->new(agent => "libwww-perl");
push @{$agent->requests_redirectable}, 'POST';

my $response = $agent->post("$base", $params);

while (my $wait = $response->header('Retry-After')) {
  print STDERR "Waiting ($wait)...\n";
  sleep $wait;
  $response = $agent->get($response->base);
}

$response->is_success ?
  print $response->content :
  die 'Failed, got ' . $response->status_line .
    ' for ' . $response->request->uri . "\n";

