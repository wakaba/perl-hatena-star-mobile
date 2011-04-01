package test::Hatena::Star::Mobile::get_star_entries;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::Hatena::Star::Mobile;
use base qw(Test::Class);

sub _minimum_new_entry : Test(1) {
    my $url = q<http://www.example.com/hsm/test/entry1> . rand;
    my $entries = Hatena::Star::Mobile->get_star_entries(
        entries => [{uri => $url}],
    );
    eq_or_diff $entries, [
        {
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{"><img src="http://s.hatena.com/images/add_gr.gif" alt="Add Star" align="middle" /></a>},
        },
    ];
}

sub _minimum_existing_entry : Test(2) {
    my $url = q<http://www.hatena.com/>;
    my $entries = Hatena::Star::Mobile->get_star_entries(
        entries => [{uri => $url}],
    );
    is ref $entries->[0]->{stars}, 'ARRAY';
    delete $entries->[0]->{stars};
    $entries->[0]->{star_html} =~ s{(?:<img[^<>]+>)+}{<IMG>}g;
    eq_or_diff $entries, [
        {
            can_comment => 0,
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{"><IMG></a><a href="http://s.hatena.com/mobile/entry?uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $url).q{&sid="><IMG></a>},
        },
    ];
}

sub _normal : Test(13) {
    my $entries = [
        {uri => 'http://d.hatena.ne.jp/jkondo/20080123/1201040123'},
        {uri => 'http://d.hatena.ne.jp/jkondo/20080122/1200947996'},
        {uri => 'http://d.hatena.ne.jp/jkondo/20080121/1200906620'},
        {uri => 'http://d.hatena.ne.jp/jkondo/20080121/dummy'},
        {uri => 'http://d.hatena.ne.jp/jkondo/20080720/1216516833'},
    ];

    my $star_entries = Hatena::Star::Mobile->get_star_entries(
        entries       => $entries,
        location      => 'http://d.hatena.ne.jp/jkondo/mobile',
        color         => 'gr',
        hatena_domain => 'hatena.ne.jp',
        sid           => 'abced',
        rks           => '12345',
    );
    
    is $Hatena::Star::Mobile::USED_HTTP_METHOD, 'GET';
    ok scalar @$star_entries;
    is scalar @$star_entries, 5;
    
    for my $se (@$star_entries) {
        like ($se->{star_html}, qr!\Qs.hatena.ne.jp/star.add\E!);
        like ($se->{star_html}, qr!\Q<img src="http://s.hatena.com/images/add_gr.gif"\E!);
    }
}

sub _with_locations : Test(9) {
    my $entries_with_locations = [
        {
            uri      => 'http://d.hatena.ne.jp/jkondo/20080123/1201040123',
            location => 'http://d.hatena.ne.jp/jkondo/20080123/1201040123#1',
        },
        {
            uri      => 'http://d.hatena.ne.jp/jkondo/20080122/dummy',
            location => 'http://d.hatena.ne.jp/jkondo/20080122/dummy#2'
        },
    ];

    my $star_entries_with_locations = Hatena::Star::Mobile->get_star_entries(
        entries       => $entries_with_locations,
        color         => 'gr',
        hatena_domain => 'hatena.ne.jp',
        sid           => 'abced',
        rks           => '12345',
    );

    is $Hatena::Star::Mobile::USED_HTTP_METHOD, 'GET';
    ok scalar @$star_entries_with_locations;
    is scalar @$star_entries_with_locations, 2;

    for my $se (@$star_entries_with_locations) {
        like ($se->{star_html}, qr!\Qs.hatena.ne.jp/star.add\E!);
        like ($se->{star_html}, qr!\Q<img src="http://s.hatena.com/images/add_gr.gif"\E!);
        like ($se->{star_html}, qr/%23(?:1|2)/);
    }
}

sub _minimum_new_entry_with_location : Test(1) {
    my $url = q<http://www.example.com/hsm/test/entry1> . rand;
    my $location = q<http://www.example.com/location>;
    my $entries = Hatena::Star::Mobile->get_star_entries(
        entries => [{uri => $url, location => $location}],
    );
    eq_or_diff $entries, [
        {
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).q{&location=}.(percent_encode_c $location).q{"><img src="http://s.hatena.com/images/add_gr.gif" alt="Add Star" align="middle" /></a>},
        },
    ];
}

sub _get_entry_url : Test(2) {
    my $url = q<http://www.hatena.com/>;
    my $entries = Hatena::Star::Mobile->get_star_entries(
        entries => [{uri => $url, location => q<location1>}],
        get_entry_url => sub {
            my ($url, $location) = @_;
            return "URL:$url;Location:$location";
        },
    );
    is ref $entries->[0]->{stars}, 'ARRAY';
    delete $entries->[0]->{stars};
    $entries->[0]->{star_html} =~ s{(?:<img[^<>]+>)+}{<IMG>}g;
    eq_or_diff $entries, [
        {
            can_comment => 0,
            uri => $url,
            star_html => q{<a href="http://s.hatena.com/star.add?sid=&rks=&uri=}.(percent_encode_c $url).qq{&location=location1"><IMG></a><a href="URL:$url;Location:location1"><IMG></a>},
        },
    ];
}

__PACKAGE__->runtests;

1;
