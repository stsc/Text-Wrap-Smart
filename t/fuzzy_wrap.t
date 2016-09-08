#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Test::More tests => 16 * 2;
use Text::Wrap::Smart qw(fuzzy_wrap wrap_smart);

my $join = sub { local $_ = shift; chomp; s/\n/ /g; $_ };

my $text = $join->(<<'EOT');
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Curabitur vel diam nec nisi pellentesque gravida a sit amet
metus. Fusce non volutpat arcu. Lorem ipsum dolor sit amet,
consectetur adipiscing elit. Donec euismod, dolor eget placerat
euismod, massa risus ultricies metus, id commodo cras amet.
EOT

my @expected = (
    [
     $join->(<<'EOT'),
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Curabitur vel diam nec nisi pellentesque gravida a sit amet metus.
Fusce non volutpat arcu.
EOT
     $join->(<<'EOT'),
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Donec euismod, dolor eget placerat euismod, massa risus
ultricies metus, id commodo cras amet.
EOT
   ], [
     'Lorem', 'ipsum', 'dolor', 'sit amet,', 'consectetur',
     'adipiscing', 'elit.', 'Curabitur', 'vel diam',
     'nec nisi', 'pellentesque', 'gravida', 'a sit',
     'amet', 'metus.', 'Fusce', 'non volutpat', 'arcu.',
     'Lorem', 'ipsum', 'dolor', 'sit amet,', 'consectetur',
     'adipiscing', 'elit.', 'Donec', 'euismod,', 'dolor',
     'eget', 'placerat', 'euismod,', 'massa', 'risus',
     'ultricies', 'metus,', 'id commodo', 'cras', 'amet.'
   ], [
     'Lorem ipsum dolor', 'sit amet,', 'consectetur adipiscing',
     'elit. Curabitur vel', 'diam nec nisi', 'pellentesque gravida',
     'a sit amet metus.', 'Fusce non volutpat', 'arcu. Lorem ipsum',
     'dolor sit amet,', 'consectetur adipiscing', 'elit. Donec euismod,',
     'dolor eget placerat', 'euismod, massa risus', 'ultricies metus, id',
     'commodo cras amet.'
   ], [
     'Lorem ipsum dolor sit amet,', 'consectetur adipiscing elit. Curabitur',
     'vel diam nec nisi pellentesque gravida', 'a sit amet metus. Fusce non volutpat',
     'arcu. Lorem ipsum dolor sit amet,', 'consectetur adipiscing elit. Donec',
     'euismod, dolor eget placerat euismod,', 'massa risus ultricies metus, id',
     'commodo cras amet.'
   ], [
     'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     'Curabitur vel diam nec nisi pellentesque gravida a sit amet',
     'metus. Fusce non volutpat arcu. Lorem ipsum dolor sit amet,',
     'consectetur adipiscing elit. Donec euismod, dolor eget',
     'placerat euismod, massa risus ultricies metus, id commodo',
     'cras amet.'
   ], [
     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vel diam',
     'nec nisi pellentesque gravida a sit amet metus. Fusce non volutpat arcu.',
     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod,',
     'dolor eget placerat euismod, massa risus ultricies metus, id commodo cras amet.'
   ], [
     $join->(<<'EOT'),
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Curabitur vel diam nec nisi pellentesque
EOT
     $join->(<<'EOT'),
gravida a sit amet metus. Fusce non volutpat arcu.
Lorem ipsum dolor sit amet, consectetur
EOT
     $join->(<<'EOT'),
adipiscing elit. Donec euismod, dolor eget placerat
euismod, massa risus ultricies metus, id commodo
EOT
     'cras amet.'
   ], [
     $join->(<<'EOT'),
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Curabitur vel diam nec nisi pellentesque gravida a sit amet
metus. Fusce non volutpat arcu.
EOT
     $join->(<<'EOT'),
Lorem ipsum dolor sit amet,
consectetur adipiscing elit. Donec euismod, dolor eget placerat
euismod, massa risus ultricies metus, id commodo cras amet.
EOT
   ],
);

my @entries = (
    [ $text, $expected[0],  2,   0 ],
    [ $text, $expected[1], 38,   5 ],
    [ $text, $expected[2], 16,  20 ],
    [ $text, $expected[3],  9,  40 ],
    [ $text, $expected[4],  6,  60 ],
    [ $text, $expected[5],  4,  75 ],
    [ $text, $expected[6],  4, 100 ],
    [ $text, $expected[7],  2, 200 ],
);

foreach my $entry (@entries) {
    test_wrap(@$entry);
    test_wrap_deprecated(@$entry);
}

sub test_wrap
{
    my ($text, $expected, $count, $wrap_at) = @_;

    my @strings = fuzzy_wrap($text, $wrap_at);

    my $length = $wrap_at ? $wrap_at : 'default';
    my $message = "(wrapping length: $length) [ordinary]";

    is(@strings, $count, "$message amount of substrings");
    is_deeply(\@strings, $expected, "$message splitted at word boundary");
}

sub test_wrap_deprecated
{
    my ($text, $expected, $count, $wrap_at) = @_;

    local $SIG{__WARN__} = sub { warn @_ unless $_[0] =~ /deprecated/ };

    my %opts = (no_split => true);
    $opts{max_msg_size} = $wrap_at if $wrap_at > 0;

    my @strings = wrap_smart($text, \%opts);

    my $length = $wrap_at ? $wrap_at : 'default';
    my $message = "(wrapping length: $length) [deprecated]";

    is(@strings, $count, "$message amount of substrings");
    is_deeply(\@strings, $expected, "$message splitted at word boundary");
}
