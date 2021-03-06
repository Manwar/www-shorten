# $Id$

=head1 NAME

WWW::Shorten::Linkz - Perl interface to lin.kz

=head1 SYNOPSIS

  use WWW::Shorten 'Linkz';

  $short_url = makeashorterlink($long_url);

  $long_url  = makealongerlink($short_url);
  $long_url  = makealongerlink($nickname);

=head1 DESCRIPTION

A Perl interface to the web site lin.kz. lin.kz simply
maintains a database of long URLs, each of which has a unique
identifier.

=cut

package WWW::Shorten::Linkz;

use 5.006;
use strict;
use warnings;

use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw(makeashorterlink makealongerlink);
our $VERSION = '1.90';

use Carp;

#POST http://lin.kz/make.php
#    url=
#    <NONAME>=Shorten URL!           (submit)
#    privkey=
#

=head1 Functions

=head2 makeashorterlink

The function C<makeashorterlink> will call the lin.kz web site
passing it your long URL and will return the shorter (Linkz) version.

Multiple submissions of the same URL will result in different codes
being returned.

=cut

sub makeashorterlink
{
    my $url = shift or croak 'No URL passed to makeashorterlink';
    my $ua = __PACKAGE__->ua();
    my $resp = $ua->post( 'http://lin.kz/make.php', [
        url => $url,
        ],
    );
    return unless $resp->is_success;
    if ($resp->content =~ m!
        \Q<a href="\E(\Qhttp://lin.kz/?\E\w+)"
        !x) {
        return $1;
    }
    return;
}

=head2 makealongerlink

The function C<makealongerlink> does the reverse. C<makealongerlink>
will accept as an argument either the full Linkz URL or just the
Linkz identifier/nickname.

If anything goes wrong, then either function will return C<undef>.

=cut

sub makealongerlink
{
    my $code = shift
        or croak 'No Linkz nickname/URL passed to makealongerlink';
    my $ua = __PACKAGE__->ua();
    $code = "http://lin.kz/?$code" unless $code =~ m!^http://!i;

    my $resp = $ua->get($code);
    my $location = $resp->header('Location');
    return $location if defined $location;
    return;
}

1;

__END__

=head2 EXPORT

makeashorterlink, makealongerlink

=head1 SUPPORT, LICENCE, THANKS and SUCH

See the main L<WWW::Shorten> docs.

=head1 AUTHOR

Iain Truskett <spoon@cpan.org>

=head1 SEE ALSO

L<WWW::Shorten>, L<perl>, L<http://lin.kz/>

=cut
