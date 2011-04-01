use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::Hatena::Star::Mobile;

use Test::More qw/no_plan/;

my $entries = [
    {uri => 'http://d.hatena.ne.jp/jkondo/20080123/1201040123'},
    {uri => 'http://d.hatena.ne.jp/jkondo/20080122/1200947996'},
    {uri => 'http://d.hatena.ne.jp/jkondo/20080121/1200906620'},
];

my $star_entries = Hatena::Star::Mobile->get_star_entries(
    entries       => $entries,
    location      => 'http://d.hatena.ne.jp/jkondo/mobile',
    color         => 'gr',
    hatena_domain => 'hatena.ne.jp',
    sid           => 'abced',
    rks           => '12345',
    use_http_post => 1,
);

is $Hatena::Star::Mobile::USED_HTTP_METHOD, 'POST';
ok scalar @$star_entries;

for my $se (@$star_entries) {
    like ($se->{star_html}, qr!\Qs.hatena.ne.jp/star.add\E!);
    like ($se->{star_html}, qr!\Q<img src="http://s.hatena.com/images/add_gr.gif"\E!);
}
