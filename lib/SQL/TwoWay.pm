package SQL::TwoWay;
use strict;
use warnings;
use 5.010001; # Named capture
our $VERSION = "0.01";
use Carp ();

use parent qw(Exporter);

our @EXPORT = qw(two_way);

sub two_way {
    my ($sql, $params) = @_;

    my @binds;
    $sql =~ s!
        # Variable /* $var */3
        (?:
            /\* \s+ \$ (?<variable> [A-Za-z0-9_-]+) \s+ \*/
            (?: "[^"]+" | -? [0-9.]+ )
        )
    !
        if (defined $+{variable}) {
            unless (exists $params->{$+{variable}}) {
                Carp::croak("Unknown variable: \$$+{variable}");
            }
            push @binds, $params->{$+{variable}};
            '?'
        }
    !gex;

    return ($sql, @binds);
}

1;
__END__

=head1 NAME

SQL::TwoWay - It's new $module

=head1 SYNOPSIS

    use SQL::TwoWay;

=head1 DESCRIPTION

SQL::TwoWay is ...

=head1 LICENSE

Copyright (C) tokuhirom

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

