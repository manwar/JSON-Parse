#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Table::Readable 'read_table';
my $in = 'errormsg.txt';
my @e = read_table ($in);
my @strings;
my @labels;
my $out = 'errors.c';
open my $o, ">", $out or die $!;
select $o;
for my $e (@e) {
    my $error = $e->{error};
    if ($error) {
	my $printed = ucfirst ($e->{error});
	my $label = $error;
	$label =~ s/\s*'%c'$//;
	$label =~ s/\s/_/g;
	push @strings, $printed;
	push @labels, $label;
    }
}

print <<EOF;
typedef enum {
EOF
for my $label (@labels) {
    print "    json_error_$label,\n";
}
print <<EOF;
    json_error_overflow
}
json_error_t;

const char * json_errors[json_error_overflow] = {
EOF
for my $printed (@strings) {
    print "    \"$printed\",\n";
}
print <<EOF;
};
EOF

my @expectations = read_table ('expectations.txt');

my @us;
my @exs;
my @ds;
for my $expectation (@expectations) {
    my $c = $expectation->{category};
    push @exs, $c;
    my $u = 'X' . uc $c;
    push @us, "#define $u (1<<x$c)";
    my $d = $expectation->{description};
    my $chrs = $expectation->{chars};
    if ($chrs) {
	my @chrs = split /\s/, $chrs;
	$d .= ": " . join ', ', (map {"'$_'"} @chrs);
	$d =~ s/\\s/ /g;
	$d =~ s/\\/\\\\/g;
	$d =~ s/"/\\"/g;
    }
    push @ds, $d;
}

print "enum expectation {\n";
for my $c (@exs) {
    print "    x$c,\n";
}
print "    n_expectations\n};\n";

for my $u (@us) {
    print "$u\n";
}

print "char * input_expectation[n_expectations] = {\n";
for my $d (@ds) {
    print "\"$d\"\n";
}
print "};\n";
exit;