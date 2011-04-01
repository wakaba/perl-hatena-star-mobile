package Hatena::Star::Mobile::Image;
use strict;
use warnings;
use URI;
use URI::Escape qw/uri_escape/;

our $VERSION = '0.05';

my $add_template =
    '<a href="%sstar.add?sid=%s&rks=%s&uri=%s&location=%s">' .
    '<img src="%s" alt="Add Star" align="middle" /></a>';

sub get_star_entries {
    my $class = shift;
    my %args = @_;
    my $entries = $args{entries} or return;
    my $hatena_domain = $args{hatena_domain} || 'hatena.com';
    my $sub_domain    = $args{sub_domain} || 's';
    my $color         = $args{color} || 'gr';
    my $add_img       = $args{add_img} || sprintf('http://s.hatena.com/images/add_%s.gif', $color);

    my $sbase = URI->new(sprintf('http://%s.%s/', $sub_domain, $hatena_domain));

    my $sentries = [];
    for my $e (@$entries) {
        next unless $e->{uri};
        my $location = $e->{location} || $args{location} || $e->{uri};
        my $html = sprintf(
            $add_template,
            $sbase, $args{sid} || '', $args{rks} || '',
            URI::Escape::uri_escape($e->{uri}),
            URI::Escape::uri_escape($location),
            $add_img,
        );
        my $star_html = sprintf q{<img src="http://s.st-hatena.com/entry.count.image?uri=%s" height="10">},
            URI::Escape::uri_escape($e->{uri});
        my $star_entry_uri;
        if ($args{get_entry_url}) {
            $star_entry_uri = $args{get_entry_url}->($e->{uri}, $location);
        } else {
            $star_entry_uri = sprintf('http://s.%s/mobile/entry?uri=%s&location=%s&sid=%s',
                                      $hatena_domain,
                                      URI::Escape::uri_escape($e->{uri}),
                                      URI::Escape::uri_escape($location),
                                      $args{sid} || '');
        }
        $star_html = sprintf('<a href="%s">%s</a>',
                             $star_entry_uri, $star_html);
        $html .= $star_html;
        push @$sentries, {
            uri => $e->{uri},
            star_html => $html,
        };
    }
    return $sentries;
}

sub find_location_by_uri {
    my ($uri, $entries) = @_;
    my ($found) = grep { $_->{uri} eq $uri } @$entries;
    $found && $found->{location} ? $found->{location} : '';
}

1;
