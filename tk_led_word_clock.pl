#!/usr/bin/perl

# https://www.thinkgeek.com/product/impi/

# Uses words to tell time
# Shows time in five minute intervals
# Words are illuminated

# It  IS  HALF  TEN
# QUARTER    TWENTY
# FIVE  MINUTES  TO
# PAST   ONE  THREE
# TWO   FOUR   FIVE
# SIX  SEVEN  EIGHT
# NINE  TEN  ELEVEN
# TWELVE    O'CLOCK

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Tk;
use Tk::Notebook;

use vars qw( %obj $_debug $_test $_verbose );

$| = 1;
srand();

$Data::Dumper::Deepcopy = 1;
$Data::Dumper::Sortkeys = 1;

$_debug   = 0;
$_test    = 0;
$_verbose = 0;

my %max = (
    x => 120, 
    y => 125,
);

GetOptions( qq{debug} => \$_debug, );

$obj{mw} = Tk::MainWindow->new();
$obj{canvas} = $obj{mw}->Canvas( -width => $max{x}, -height => $max{y}, -background => q{#000000}, )->pack();
$obj{image} = $obj{mw}->Photo( -width => $max{x}, -height => $max{y}, -palette => q{256/256/256}, );
$obj{image}->blank;
$obj{canvas}->createImage( 0, 0, -image => $obj{image}, -anchor => q{nw}, );

# for ( my $x = 0; $x < $max{x}; $x += 10 ) {
#     $obj{canvas}->createLine( $x, 0, $x, $max{y} - 1, -fill => q{#00FF00}, );
# }
# for ( my $y = 0; $y < $max{y}; $y += 10 ) {
#     $obj{canvas}->createLine( 0, $y, $max{x} - 1, $y, -fill => q{#00FF00}, );
# }

my @objconf = (
    [
        { id => q{it},      x => 5,  txt => q{IT},   },
        { id => q{is},      x => 25, txt => q{IS},   },
        { id => q{half},    x => 45, txt => q{HALF}, },
        { id => q{ten_min}, x => 90, txt => q{TEN},  },
    ],
    [
        { id => q{quarter}, x => 5,  txt => q{QUARTER}, },
        { id => q{twenty},  x => 65, txt => q{TWENTY},  },
    ],
    [
        { id => q{five_min}, x => 5,  txt => q{FIVE},    },
        { id => q{minutes},  x => 40, txt => q{MINUTES}, },
        { id => q{to},       x => 98, txt => q{TO},      },
    ],
    [
        { id => q{past},  x => 5,  txt => q{PAST},  },
        { id => q{one},   x => 45, txt => q{ONE},   },
        { id => q{three}, x => 75, txt => q{THREE}, },
    ],
    [
        { id => q{two},     x => 5,  txt => q{TWO}, },
        { id => q{four},    x => 40, txt => q{FOUR}, },
        { id => q{five_hr}, x => 87, txt => q{FIVE}, },
    ],
    [
        { id => q{six}, x => 5, txt => q{SIX}, },
        { id => q{seven}, x => 35, txt => q{SEVEN}, },
        { id => q{eight}, x => 80, txt => q{EIGHT}, },
    ],
    [
        { id => q{nine},   x => 5,  txt => q{NINE},   },
        { id => q{ten_hr}, x => 37, txt => q{TEN},    },
        { id => q{eleven}, x => 70, txt => q{ELEVEN}, },
    ],
    [
        { id => q{twelve},  x => 5,  txt => q{TWELVE},  },
        { id => q{o_clock}, x => 65, txt => q{O'CLOCK}, },
    ],
);

foreach my $i ( 0 .. $#objconf ) { 
    my $y = 5 + $i * 15;
    foreach my $j ( 0 .. $#{$objconf[$i]} ) {
        $obj{word}{$objconf[$i][$j]{id}} = 
            $obj{canvas}->createText( $objconf[$i][$j]{x}, $y, -anchor => q{nw}, -fill => q{#FF3333}, -text => $objconf[$i][$j]{txt}, -tags => [ q{word}, $objconf[$i][$j]{id}, ], );
    }
}

# It  IS  HALF  TEN
# QUARTER    TWENTY
# FIVE  MINUTES  TO
# PAST   ONE  THREE
# TWO   FOUR   FIVE
# SIX  SEVEN  EIGHT
# NINE  TEN  ELEVEN
# TWELVE    O'CLOCK

$obj{canvas}->after( 1250, \&update );

$obj{repeat} = $obj{canvas}->repeat( 5000, \&update );

MainLoop;

#
# Subroutines
#
sub update {

    # Active:
    # IT IS
    # 00 - O'CLOCK
    # 05 55 - FIVE MINUTES TO/PAST
    # 10 50 - TEN MINUTES TO/PAST
    # 15 45 - QUARTER TO/PAST
    # 20 40 - TWENTY TO/PAST
    # 25 35 - TWENTY FIVE TO/PAST 
    # 30 - HALF PAST

    my %translate = (
        hr => {
            0 => [ q{twelve}, ],
            1 => [ q{one}, ],
            2 => [ q{two}, ],
            3 => [ q{three}, ],
            4 => [ q{four}, ],
            5 => [ q{five_hr}, ],
            6 => [ q{six}, ],
            7 => [ q{seven}, ],
            8 => [ q{eight}, ],
            9 => [ q{nine}, ],
            10 => [ q{ten_hr}, ],
            11 => [ q{eleven}, ],
            12 => [ q{twelve}, ],
        },
        min => {
            0 => [ q{half}, ],
            1 => [ q{twenty}, q{five_min}, ], 
            2 => [ q{twenty}, ],
            3 => [ q{quarter}, ],
            4 => [ q{ten_min}, ],
            5 => [ q{five_min}, ],
            6 => [ q{o_clock}, ],
        },
    );
   
    my @lt = localtime(time);

    my $hour = $lt[2] % 12;
    $hour = 12 unless ( $hour );
    my $minute = $lt[1] - ( $lt[1] % 5 );
    my $direction = ( $minute > 30 );
    $minute = abs( 30 - $minute ) / 5;

    # print __FILE__ . q{:} . __LINE__ . q{: } . qq{\n};
    
    foreach my $k ( keys %{$obj{word}} ) {
        $obj{canvas}->itemconfigure( $obj{word}{$k}, -fill => q{#000033}, );
    }

    $obj{canvas}->itemconfigure( $obj{word}{it}, -fill => q{#0066FF}, );
    $obj{canvas}->itemconfigure( $obj{word}{is}, -fill => q{#0066FF}, );

    foreach my $k ( qw( it is ), @{$translate{min}{$minute}}, ( $minute == 6 ? () : $direction ? q{to} : q{past} ), @{$translate{hr}{$hour + $direction}}, ) {
        $obj{canvas}->itemconfigure( $obj{word}{$k}, -fill => q{#0066FF}, );
    }

}

BEGIN {
    if ( $^O eq q{MSWin32} ) {
        eval {
            require Win32::Console;
        };
        if ( not length $@ ) {
            Win32::Console::Free();
        }
    }
}

__END__

=pod

=head1 tk-led-word-clock.pl

tk-led-word-clock.pl - a perl/Tk clock implementation of the LED Word Clock

A representation of L<LED Word Clock|https://www.thinkgeek.com/product/impi/>.

=over

=item *
    Uses words to tell time. (Appropriate words are illuminated.)

=item *
    Shows time in five minute intervals. (10:37 would be given as "It is twenty five to eleven".)

=item *
    Display updates approximately every 5s.

=back

=cut

