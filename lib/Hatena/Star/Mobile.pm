package Hatena::Star::Mobile;
use strict;
use warnings;

use Carp qw/croak/;
use HTTP::Request;
use JSON::Syck;
use LWP::UserAgent;
use URI;
use URI::QueryParam;
use URI::Escape qw/uri_escape/;

our $VERSION = '0.05';
our $USED_HTTP_METHOD;  ## for testing

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
    my $random_key    = $args{random_key}; # for viewable;
    my $timeout       = $args{timeout};
    my $backend_ip    = $args{backend_ip};
    my $use_eval      = $args{use_eval};

    my $sbase = URI->new(sprintf('http://%s.%s/', $sub_domain, $hatena_domain));

    my $suri  = ($backend_ip) ? URI->new(sprintf('http://%s/',$backend_ip)) : $sbase->clone;
    $suri->path('entries.mobile.json');

    my $ua = LWP::UserAgent->new;
    $ua->agent(sprintf "%s/%s", __PACKAGE__, $VERSION);
    $ua->timeout($timeout) if $timeout;
    eval {
        $ua->use_eval(1) if $use_eval;
    };
    warn $@ if $@;
    my $req = HTTP::Request->new;
    my $sentries = [];
    my $do_http_request = 0;

    if ($random_key) {
        $req->header(Cookie => sprintf('rk=%s', $random_key));
    }

    if (!$args{use_http_post}) {
        $suri->query_param_append(sid => $args{sid}) if $args{sid};
        for my $e (@$entries) {
            next unless $e->{uri};
            $suri->query_param_append(uri => $e->{uri});
            $do_http_request++;
        }

        $req->method('GET');
        $req->uri($suri);
        $USED_HTTP_METHOD = 'GET';
    } else {
        my $content = join '&', map { sprintf "uri=%s", uri_escape($_->{uri}) } @$entries ;
        $do_http_request++ if defined $content;

        $req->uri($suri);
        $req->method('POST');
        $req->content($content);
        $USED_HTTP_METHOD = 'POST';
    }

    if ($do_http_request) {
        my $res;
        eval {
            $res = $ua->request($req);
        };
        if ($@) {
            warn $@;
            return;
        }
        if (not $res->is_success) {
            warn $res->status_line;
            return;
        }

        my $data = JSON::Syck::Load($res->content);
        $sentries = $data->{entries};
    }

    my %known;
    for my $se (@$sentries) {
        next unless ($se && $se->{uri});
        $known{$se->{uri}}++;
        my $location = find_location_by_uri($se->{uri}, $entries) || $args{location} || $se->{uri};
        my $html = sprintf(
            $add_template,
            $sbase, $args{sid} || '', $args{rks} || '',
            URI::Escape::uri_escape($se->{uri}),
            URI::Escape::uri_escape($location),
            $add_img,
        );
        my $star_html = '';

        for my $cs (@{ $se->{colored_stars} || [] }) {
            for my $s (@{ $cs->{stars} }) {
                if (ref $s eq 'HASH') {
                    $star_html .= sprintf('<img src="%simages/star-%s.gif" alt="%s" align="middle" />',
                                     $sbase, $cs->{color}, $s->{name});
                } else {
                    $star_html .= sprintf('<font color="#f4b128">%d</font>',$s);
                }
            }
        }

        for my $s (@{$se->{stars}}) {
            if (ref $s eq 'HASH') {
                $star_html .= sprintf('<img src="%simages/star.gif" alt="%s" align="middle" />',
                                 $sbase, $s->{name});
            } else {
                $star_html .= sprintf('<font color="#f4b128">%d</font>',$s);
            }
        }
        my $star_entry_uri;
        if ($args{get_entry_url}) {
            $star_entry_uri = $args{get_entry_url}->($se->{uri}, $location);
        } else {
            $star_entry_uri = sprintf('http://s.%s/mobile/entry?uri=%s&location=%s&sid=%s',
                                      $hatena_domain,
                                      URI::Escape::uri_escape($se->{uri}),
                                      URI::Escape::uri_escape($location),
                                      $args{sid} || '');
        }
        $star_html = sprintf('<a href="%s">%s</a>',
                             $star_entry_uri, $star_html);
        $html .= $star_html;
        $se->{star_html} = $html;
    }
    for my $e (@$entries) {
        next unless $e->{uri};
        next if $known{$e->{uri}};
        my $html = sprintf(
            $add_template,
            $sbase, $args{sid} || '', $args{rks} || '',
            URI::Escape::uri_escape($e->{uri}),
            URI::Escape::uri_escape($e->{location} || $args{location} || $e->{uri}),
            $add_img,
        );
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
