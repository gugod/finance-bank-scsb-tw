package Finance::Bank::SCSB::TW::CurrencyExchangeRateCollection;
use strict;
use warnings;

sub for_currency {
    my $self = shift;
    my $currency_name = shift;

    my @ret = ();
    for my $c (@$self) {
        if ($c->{en_currency_name} =~ /\Q${currency_name}\E/i) {
            push @ret, $c;
        }
    }

    return \@ret;
}


1;
