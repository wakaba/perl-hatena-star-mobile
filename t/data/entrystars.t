package test::Hatena::Star::Data::EntryStars;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;
use Test::Differences;
use Hatena::Star::Data::EntryStars;

sub _expanded_entry_data_to_entry_user_stars_data : Test(10) {
    for (
        [{stars => []} => []],
        [{stars => [
            {name => 'a'}, {name => 'b'},
        ]} => [
            {name => 'a', stars => {yellow => 1}},
            {name => 'b', stars => {yellow => 1}},
        ]],
        [{stars => [
            {name => 'a'}, {name => 'b'}, {name => 'a'},
        ]} => [
            {name => 'a', stars => {yellow => 2}},
            {name => 'b', stars => {yellow => 1}},
        ]],
        [{stars => [
            {name => 'a'}, {name => 'b', count => 300},
        ]} => [
            {name => 'a', stars => {yellow => 1}},
            {name => 'b', stars => {yellow => 300}},
        ]],
        [{stars => [
            {name => 'a'}, {name => 'b'},
        ], colored_stars => [
            {color => 'red', stars => [
                {name => 'c'},
                {name => 'a'},
            ]},
        ]} => [
            {name => 'c', stars => {red => 1}},
            {name => 'a', stars => {yellow => 1, red => 1}},
            {name => 'b', stars => {yellow => 1}},
        ]],
        [{stars => [
            {name => 'a'}, {name => 'b'},
        ], colored_stars => [
            {color => 'red', stars => [
                {name => 'c'},
                {name => 'a'},
            ]},
            {color => 'green', stars => [
                {name => 'd'},
            ]},
        ]} => [
            {name => 'c', stars => {red => 1}},
            {name => 'a', stars => {yellow => 1, red => 1}},
            {name => 'd', stars => {green => 1}},
            {name => 'b', stars => {yellow => 1}},
        ]],
        [{stars => [], colored_stars => [
            {color => 'red', stars => [
                {name => 'c'},
                {name => 'a'},
            ]},
            {color => 'green', stars => [
                {name => 'd'},
            ]},
        ]} => [
            {name => 'c', stars => {red => 1}},
            {name => 'a', stars => {red => 1}},
            {name => 'd', stars => {green => 1}},
        ]],
        [{stars => [
            {name => 'a'}, {name => 'b', count => 300},
        ], colored_stars => [
            {color => 'red', stars => [
                {name => 'c'},
                {name => 'a', count => 200},
            ]},
        ]} => [
            {name => 'c', stars => {red => 1}},
            {name => 'a', stars => {yellow => 1, red => 200}},
            {name => 'b', stars => {yellow => 300}},
        ]],
        [{stars => [
            {name => 'a', quote => 'b'},
        ]} => [
            {name => 'a', stars => {yellow => 1}, quotes => ['b']},
        ]],
        [{stars => [
            {name => 'a', quote => 'b'},
            {name => 'c', quote => ''},
        ], colored_stars => [
            {color => 'red', stars => [
                {name => 'c', quote => 'd'},
                {name => 'c', quote => 'd'},
            ]},
        ]} => [
            {name => 'c', stars => {yellow => 1, red => 2}, quotes => ['d', 'd']},
            {name => 'a', stars => {yellow => 1}, quotes => ['b']},
        ]],
    ) {
        my $output = Hatena::Star::Data::EntryStars->expanded_entry_data_to_entry_user_stars_data($_->[0]);
        eq_or_diff $output, $_->[1];
    }
}

__PACKAGE__->runtests;

1;
