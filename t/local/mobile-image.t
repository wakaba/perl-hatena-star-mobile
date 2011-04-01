package test::Hatena::Star::Mobile::Image;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::Hatena::Star::Mobile;
use base qw(Test::Class);

sub _minimum_new_entry : Test(1) {
    my $url = q<http://www.example.com/hsm/test/entry1> . rand;
    my $entries = Hatena::Star::Mobile::Image->get_star_entries(
        entries => [{uri => $url}],
    );
    eq_or_diff $entries, [
        {
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{"><img src="http://s.hatena.com/images/add_gr.gif" alt="Add Star" align="middle" /></a><a href="http://s.hatena.com/mobile/entry?uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{&sid="><img src="http://s.st-hatena.com/entry.count.image?uri=}.(percent_encode_c $url).q{" height="10"></a>},
        },
    ];
}

sub _minimum_existing_entry : Test(2) {
    my $url = q<http://www.hatena.com/>;
    my $entries = Hatena::Star::Mobile::Image->get_star_entries(
        entries => [{uri => $url}],
    );
    ok !$entries->[0]->{stars};
    eq_or_diff $entries, [
        {
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{"><img src="http://s.hatena.com/images/add_gr.gif" alt="Add Star" align="middle" /></a><a href="http://s.hatena.com/mobile/entry?uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{&sid="><img src="http://s.st-hatena.com/entry.count.image?uri=}.(percent_encode_c $url).q{" height="10"></a>},
        },
    ];
}

sub _minimum_new_entry_with_location : Test(1) {
    my $url = q<http://www.example.com/hsm/test/entry1> . rand;
    my $location = q<http://www.example.com/location>;
    my $entries = Hatena::Star::Mobile::Image->get_star_entries(
        entries => [{uri => $url, location => $location}],
    );
    eq_or_diff $entries, [
        {
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $location).q{"><img src="http://s.hatena.com/images/add_gr.gif" alt="Add Star" align="middle" /></a><a href="http://s.hatena.com/mobile/entry?uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $location).q{&sid="><img src="http://s.st-hatena.com/entry.count.image?uri=}.(percent_encode_c $url).q{" height="10"></a>},
        },
    ];
}

sub _get_entry_url : Test(2) {
    my $url = q<http://www.hatena.com/>;
    my $entries = Hatena::Star::Mobile::Image->get_star_entries(
        entries => [{uri => $url, location => q<location1>}],
        get_entry_url => sub {
            my ($url, $location) = @_;
            return "URL:$url;Location:$location";
        },
    );
    ok !$entries->[0]->{stars};
    $entries->[0]->{star_html} =~ s{(?:<img[^<>]+>)+}{<IMG>}g;
    eq_or_diff $entries, [
        {
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).qq{&location=location1"><IMG></a><a href="URL:$url;Location:location1"><IMG></a>},
        },
    ];
}

__PACKAGE__->runtests;

1;
