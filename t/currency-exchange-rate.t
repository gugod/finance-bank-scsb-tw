use strict;
use Finance::Bank::SCSB::TW;
use Test::More;

unless ($ENV{TEST_SCSB_BANK}) {
    plan skip_all => 'Testing requires it to hit scsb.com.tw website. Set TEST_SCSB_BANK env variable for reallying running the test.';
}
else {
    plan tests => 3;
}

my $rate = Finance::Bank::SCSB::TW->currency_exchange_rate;

is(ref($rate), 'ARRAY');
is(ref($rate->[0]), 'HASH');
is($rate->[0]{en_currency_name}, 'USD CASH');
