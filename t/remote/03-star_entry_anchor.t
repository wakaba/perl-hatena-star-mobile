use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::Hatena::Star::Mobile;

use Test::More qw/no_plan/;

my $entries = [
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


for my $se (@$star_entries) {
    like ($se->{star_html}, qr!\Qs.hatena.ne.jp/star.add\E!);
    like ($se->{star_html}, qr!\Q<img src="http://s.hatena.com/images/add_gr.gif"\E!);
    like ($se->{star_html}, qr!\Q<a href="http://s.hatena.ne.jp/mobile/entry?uri=http%3A%2F%2Fd.hatena.ne.jp%2Fjkondo%2F20080720%2F1216516833\E!);
}
