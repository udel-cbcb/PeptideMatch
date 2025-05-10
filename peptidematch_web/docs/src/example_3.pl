use strict;
use warnings;
use LWP::UserAgent;

my $base = 'http://alanine.bioinformatics.udel.edu/peptidematch_new/webservices/peptidematch_rest';

my $params = {
  format => 'tab',
  query => 'DPETERQ',
  organism => '5888,537012'
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

