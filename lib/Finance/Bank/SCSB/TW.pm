use strict;

package Finance::Bank::SCSB::TW;

use Carp;
use 5.008;
our $VERSION = '0.10';
use WWW::Mechanize;
use HTML::Selector::XPath qw(selector_to_xpath);
use HTML::TreeBuilder::XPath;
use utf8;
use List::MoreUtils qw(mesh);

{
    my $ua;
    sub ua {
        return $ua if $ua;
        $ua = WWW::Mechanize->new(
            env_proxy => 1,
            keep_alive => 1,
            timeout => 60,
        );
    }
}

sub check_balance {
    die "Not implemented";
}

sub currency_exchange_rate {
    my $url = 'https://ibank.scsb.com.tw/netbank.portal?_nfpb=true&_pageLabel=page_other12&_nfls=false';
    ua->get($url);
    my $content = ua->content;

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse($content);

    my @xp = map {
        [ map { $_->as_trimmed_text } $tree->findnodes($_) ]
    } (
        selector_to_xpath("td.txt09 > span"),
        selector_to_xpath("td.txt09 + td > span"),
        selector_to_xpath("td.txt09 + td + td.txt101 > span"),
        selector_to_xpath("td.txt09 + td + td.txt101 + td.txt101 > span")
    );

    my $table = [];
    my @field_names = qw(zh_currency_name en_currency_name buy_at sell_at);
    for my $row (0..scalar(@{$xp[0]})-1) {
        my @row = ();
        for my $node_text (@xp) {
            my $str = $node_text->[$row];
            utf8::decode($str);
            push @row, $str;
        }
        $row[0] =~ s/\p{IsSpace}+//g;

        push @$table, { mesh @field_names, @row };
    }

    return $table;
}

1;

__END__

=head1 NAME

Finance::Bank::SCSB::TW - Check Taiawn SCSB bank info

=head1 SYNOPSIS

    use Finance::Bank::SCSB::TW;

    my $rate = Finance::Bank::SCSB::TW::currency_exchange_rate

    print YAML::Dump($rate);

=head1 DESCRIPTION

This module provides a rudimentary interface to the Fubon eBank
banking system at L<http://www.scsb.com.tw/>.

You will need either B<Crypt::SSLeay> or B<IO::Socket::SSL> installed
for HTTPS support to work with LWP.

=head1 FUNCTIONS

=over 4

=item currency_exchange_rate

Retrieve the table of foriegn currency exchange rate. All rates are
exchanged with NTD. It returns an arrayref of hash with each one looks
like this:

    {
        zh_currency_name => "美金現金",
        en_currency_name => "USD CASH",
        buy_at           => 33.06,
        sell_at          => 33.56
    }

=item check_balance(username => $u, password => $p, account=>$a )

This function isn't re-implemented yet. Please do not use this function.

=back

=head1 WARNING

This is code for B<online banking>, and that means B<your money>, and
that means B<BE CAREFUL>. You are encouraged, nay, expected, to audit
the source of this module yourself to reassure yourself that I am not
doing anything untoward with your banking data. This software is useful
to me, but is provided under B<NO GUARANTEE>, explicit or implied.

=head1 AUTHORS

Kang-min Liu E<lt>gugod@gugod.orgE<gt>

Based on B<Finance::Bank::LloydTSB> by Simon Cozens C<simon@cpan.org>,
and B<Finance::Bank::Fubon::TW> by Autrijus Tang C<autrijus@autrijus.org>

=head1 COPYRIGHT

Copyright 2003,2004,2005,2006,2007,2008 by Kang-min Liu E<lt>gugod@gugod.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

