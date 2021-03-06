#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use JSON::Parse ':all';
use Test::More;
$JSON::Parse::json_diagnostics = 1;
eval {
    assert_valid_json ("baba");
};
my $error = $@;
#note ($@);
$JSON::Parse::json_diagnostics = 0;
my $j;
eval {
    $j = parse_json ($error);
};
ok (! $@, "got valid JSON error message");
#print "$error\n";
my @valid = ("\t", "\r", "\n", ' ', '{', '[', '0'..'9', '-', '"', 't', 'f', 'n'); 
my @valid_bytes = (0) x 256;
for (@valid) {
#    print ord ($_), "\n";
    $valid_bytes[ord ($_)] = 1;
}
#for my $i (0..$#{$j->{'valid bytes'}}) {
#    printf "%3d:$j->{'valid bytes'}->[$i]/$valid_bytes[$i] ", $i;
#}
#print "\n";
is_deeply ($j->{"valid bytes"}, \@valid_bytes, "valid bytes same");

$JSON::Parse::json_diagnostics = 1;

my $loonie = '[1,loonie]';
eval {
    assert_valid_json ($loonie);
};
ok ($@);
note "$@\n";
my $j2 = parse_json ($@);
is ($j2->{'bad byte contents'}, ord ('l'));
is ($j2->{'bad byte position'}, 4);

#note ($@);
done_testing ();
