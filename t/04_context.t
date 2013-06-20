use strict;
use warnings;
use utf8;
use Test::More;
use SQL::TwoWay;

my $in       = q{SELECT * FROM foo WHERE bar = /* $bar */'bar'};
my $expected = 'SELECT * FROM foo WHERE bar = ?';
my $vars     = { bar => 'baz' };

subtest 'list context' => sub {
    my ($got, @bind) = two_way_sql($in, $vars);
    is $got, $expected;
    is_deeply \@bind, [ 'baz' ];
};

subtest 'scalar context' => sub {
    my $got = two_way_sql( $in, $vars );
    is $got, $expected;
};

done_testing;
