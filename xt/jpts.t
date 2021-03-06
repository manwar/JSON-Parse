# JSON Parse Test Suite tests

use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";
use JSON::Parse ':all';

my $dir = "$Bin/jpts";
my @y = <$dir/y_*>;
my @n = <$dir/n_*>;

# Catch warnings
my $warning;
$SIG{__WARN__} = sub {
    $warning = "@_";
};

for my $y (@y) {
    my $text = get_text ($y);
    eval {
	assert_valid_json ($text);
    };
    ok (! $@, "assert_valid_json $y ok");
    eval {
	my $discarded = parse_json ($text);
    };
    ok (! $@, "parse_json $y ok");
    ok (valid_json ($text), "valid_json $y yes");
    my $dup = ($y =~ /duplicate/);
    # undef, 0, and "" are all "false" as far as Perl's concerned.
    my $expect_false = ($y =~ /lonely_(null|false)|structure_string_empty/);
    if (! $dup) {
	note ($y);
	my $out = parse_json_safe ($text);
	if (! $expect_false) {
	    ok ($out, "valid output with $y");
	}
	ok (! $warning, "no warning with $y");
    }
    $warning = undef;
}
for my $n (@n) {
    my $text = get_text ($n);
    eval {
	assert_valid_json ($text);
    };
    ok ($@, "assert_valid_json $n failed");
    eval {
	my $discarded = parse_json ($text);
    };
    ok ($@, "parse_json $n failed");
    ok (! valid_json ($text), "valid_json $n no");
    my $out = parse_json_safe ($text);
    ok (! $out, "parse_json_safe gave no output with $n");
    ok ($warning, "parse_json_safe gave a warning with $n");
    $warning = undef;
}

done_testing ();
exit;

sub get_text
{
my ($file) = @_;
my $text = '';
open my $in, "<", $file or die $!;
while (<$in>) {
$text .= $_;
}
return $text;
}
