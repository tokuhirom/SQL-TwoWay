use strict;
use warnings;
use utf8;
use Test::More;

use SQL::TwoWay;

subtest 'No operation' => sub {
    match(
        'Positive Int',
        q{SELECT * FROM foo}, { },
        q{SELECT * FROM foo}, []
    );
};

subtest 'Simple replacement' => sub {
    match(
        'Positive Int',
        q{SELECT * FROM foo WHERE boo=/* $b */3}, { b => 4 },
        q{SELECT * FROM foo WHERE boo=?}, [4]
    );
    match(
        'Negative Int',
        q{SELECT * FROM foo WHERE boo=/* $b */-3}, { b => -4 },
        q{SELECT * FROM foo WHERE boo=?}, [-4]
    );
    match(
        'Positive Double',
        q{SELECT * FROM foo WHERE boo=/* $b */3.14}, { b => 1.41421356 },
        q{SELECT * FROM foo WHERE boo=?}, [1.41421356]
    );
    match(
        'String',
        q{SELECT * FROM foo WHERE boo=/* $b */"WoW"}, { b => "Gah!" },
        q{SELECT * FROM foo WHERE boo=?}, ['Gah!']
    );
};

subtest 'IF statement' => sub {
    match(
        'Simple, true',
        q{SELECT * FROM foo /* IF $cond */WHERE 1=1/* END */}, { cond => 1 },
        q{SELECT * FROM foo WHERE 1=1}, [],
    );
    match(
        'Simple, false',
        q{SELECT * FROM foo /* IF $cond */WHERE 1=1/* END */}, { cond => 0 },
        q{SELECT * FROM foo }, [],
    );
    match(
        'IF-ELSE, true',
        q{SELECT * FROM foo WHERE /* IF $cond */b=/* $b */5/* ELSE */c=/* $c */7/* END */}, { cond => 1, b => 3, c => 8 },
        q{SELECT * FROM foo WHERE b=?}, [3],
    );
    match(
        'IF-ELSE, false',
        q{SELECT * FROM foo WHERE /* IF $cond */b=/* $b */5/* ELSE */c=/* $c */7/* END */}, { cond => 0, b => 3, c => 8 },
        q{SELECT * FROM foo WHERE c=?}, [8],
    );
};

done_testing;

sub match {
    my ($name, $sql, $params, $expected_sql, $expected_binds) = @_;

    subtest $name => sub {
        my ($sql, @binds) = two_way($sql, $params);
        is($sql, $expected_sql);
        is(0+@binds, 0+@$expected_binds);
        for (0..@$expected_binds-1) {
            is($binds[$_], $expected_binds->[$_]);
        }
    };
}
