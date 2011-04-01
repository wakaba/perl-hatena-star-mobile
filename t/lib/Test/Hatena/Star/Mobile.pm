package Test::Hatena::Star::Mobile;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->parent->parent->parent->subdir('lib')->stringify;
use Test::More;
use Test::Differences;
use Hatena::Star::Mobile;
use Hatena::Star::Mobile::Image;
use Exporter::Lite;

our @EXPORT = (@Test::More::EXPORT, @Test::Differences::EXPORT, qw(
    percent_encode_c
));

sub percent_encode_c ($) {
  require Encode;
  my $s = Encode::encode ('utf8', ''.$_[0]);
  $s =~ s/([^0-9A-Za-z._~-])/sprintf '%%%02X', ord $1/ge;
  return $s;
} # percent_encode_c

1;
