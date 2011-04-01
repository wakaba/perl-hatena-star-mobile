package Hatena::Star::Data::EntryStars;
use strict;
use warnings;
our $VERSION = '1.0';

sub expanded_entry_data_to_entry_user_stars_data {
    my ($class, $expanded_entry_data) = @_;

    my $stars = [];
    my $name_to_star = {};
    
    for (@{$expanded_entry_data->{colored_stars} or []}, $expanded_entry_data) {
        my $color = $_->{color} || 'yellow';

        for (@{$_->{stars}}) {
            my $name = $_->{name};

            my $s = $name_to_star->{$name};
            if ($s) {
                $s->{stars}->{$color} += $_->{count} || 1;
            } else {
                push @$stars, $s = $name_to_star->{$name} = {
                    name  => $name,
                    stars => { $color => $_->{count} || 1 },
                };
            }
            if (defined $_->{quote} and length $_->{quote}) {
                push @{$s->{quotes} ||= []}, $_->{quote};
            }
        }
    }

    return $stars;
}

1;
