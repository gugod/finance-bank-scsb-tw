
package Finance::Bank::SCSB::TW;
use strict;
use Carp;
our $VERSION = '0.02';
use WWW::Mechanize;
use HTML::Selector::XPath qw(selector_to_xpath);
use HTML::TreeBuilder::XPath;

our $ua = WWW::Mechanize->new(
    env_proxy => 1,
    keep_alive => 1,
    timeout => 60,
);

sub check_balance {
	my ($u,$p,$a) = @_;

 	croak "Must provide a username" unless $u;
	croak "Must provide a password" unless $p;
	croak "Must provide a account number" unless $a;

	$ua->get('https://netbank.scsb.com.tw/scripts/down_menu1.asp');
	$ua->get('https://netbank.scsb.com.tw/check_in_personal.htm');
	$ua->field(Var1 => $u);
	$ua->field(Var2 => $p);
	$ua->submit;
	$ua->get('https://netbank.scsb.com.tw/personal_bank.htm');
	$ua->get('https://netbank.scsb.com.tw/scripts/scsb.exe?App=Tr1801_in');
	$ua->field(Var1 => $a);
	$ua->submit;

	my $content = $ua->content;

	# logout
	$ua->get('https://netbank.scsb.com.tw/scripts/scsb.exe?App=Logoff&Pno=1');

	# parse html
	$content =~ m{
<TD\ align=right><FONT\ color=#008000\ size=4><B>([^<>]+?)</B></FONT></TD>\s
<TD\ align=right><FONT\ color=#0000FF\ size=4><B>([\d,.]+?)</B></FONT></TD>\s
</TR>\s
<TR><TD\ align=right><FONT\ color=#008000\ size=4><B>([^<>]+?)</B></FONT></TD>\s
<TD\ align=right><FONT\ color=#0000FF\ size=4><B>([\d,.]+?)</B></FONT></TD>\s
}s;

	return {
		account => $a,
		credit => $2,
		balance => $4,	
	};
}

sub currency_exchange_rate {
    my $url = 'https://ibank.scsb.com.tw/netbank.portal?_nfpb=true&_pageLabel=page_other12&_nfls=false';
    $ua->get($url);
    my $content = $ua->content;

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
    for my $row (0..scalar(@{$xp[0]})-1) {
        my @row = ();
        for my $node_text (@xp) {
            push @row, $node_text->[$row];
        }
        push @$table, {
            currency => "$row[0] ($row[1])",
            buy_at => $row[2],
            sell_at => $row[3]
        };
    }

    return $table;
}

__END__

=head1 NAME

Finance::Bank::SCSB::TW - Check SCSB accounts from Perl

=head1 SYNOPSIS

    use Finance::Bank::SCSB::TW;

    my $scsb = Finance::Bank::SCSB::TW::check_balance($username,$password,$account);

    foreach (keys %$scsb) {
        print "$_ : " . $scsb->{$_}. "\n";
    }

=head1 DESCRIPTION

This module provides a rudimentary interface to the Fubon eBank
banking system at L<http://www.scsb.com.tw/>.

You will need either B<Crypt::SSLeay> or B<IO::Socket::SSL> installed
for HTTPS support to work with LWP.

=head1 CLASS METHODS

    check_balance(username => $u, password => $p, account=>$a )

Return your balance information for account number $a.

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

