#!/usr/bin/perl

# http://www.anelace.com/Crystal_Blue.html
# http://www.thinkgeek.com/product/59e0/

use strict;
use warnings;

use vars qw( %clock  $_debug $_test $_verbose );

use Data::Dumper;
use Getopt::Long;
use Tk;
use Tk::ProgressBar;

$| = 1;
srand();
$Data::Dumper::Deepcopy = 1;
$Data::Dumper::Sortkeys = 1;

$_debug   = 0;
$_test    = 0;
$_verbose = 0;

GetOptions(
    qq{debug} => \$_debug,
);

$clock{setting}{time_display}      = 0;
$clock{setting}{time_mode}         = 0;
$clock{setting}{hour_mode}         = 0;
$clock{setting}{brightness}        = 2;
$clock{setting}{outline}           = 1;
$clock{setting}{cheat_mode}        = 1;
$clock{setting}{color}{0}          = q{#008};
$clock{setting}{color}{1}          = q{#00C};
$clock{setting}{color}{2}          = q{#00F};
$clock{setting}{outline_color}{0}  = q{#000};
$clock{setting}{outline_color}{1}  = q{#008};
$clock{setting}{time}              = q{00:00:00};
$clock{setting}{day_second}        = 0;
$clock{setting}{show_progress_bar} = 1;
$clock{setting}{show_progress_bar_processed} = $clock{setting}{show_progress_bar};

$clock{main} = new MainWindow;

my $interface_row = 0;

$clock{display} =
  $clock{main}->Frame()
  ->grid( -column => 0, -columnspan => 4, -row => $interface_row, );
$clock{display}{canvas} =
  $clock{display}->Canvas( -height => 240, -width => 320, )
  ->grid( -column => 0, -columnspan => 4, -row => $interface_row, );

$interface_row++;

$clock{display}{label} = $clock{display}->Label(
    -textvariable => \$clock{setting}{time},
    -state        => q{normal},
)->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
$clock{display}{label2} = $clock{display}->Label(
    -textvariable => \$clock{setting}{day_second},
    -state        => q{normal},
)->grid( -column => 2, -columnspan => 2, -row => $interface_row, );

$interface_row++;

$clock{display}{canvas_ph_1} = $clock{display}->Canvas( -height => 20, -width => 1, )->grid( -column => 0, -row => $interface_row, );
$clock{display}{progress_bar} = $clock{display}->ProgressBar(
    -width  => 20,
    -length => 320,
    -anchor => q{w},
    -from   => 0,
    -to     => 86400,
    -blocks => 24,
    -colors => [
        0,     'blue',   21600, 'green',
        43200, 'yellow', 64800, 'red',
    ],
    -variable => \$clock{setting}{day_second},
)->grid( -column => 1, -columnspan => 4, -row => $interface_row, );
$clock{display}{canvas_ph_2} = $clock{display}->Canvas( -height => 20, -width => 1, )->grid( -column => 5, -row => $interface_row, );

{
    my $active   = q{#3333FF};
    my $disabled = q{#000099};
    my $border   = q{#000066};
    my $empty    = q{#000000};
    $clock{display}{canvas}{bg} =
      $clock{display}{canvas}
      ->createRectangle( 0, 0, 320, 240, -fill => $empty, );
    foreach my $column ( 0 .. 5 ) {
        foreach my $row ( 0 .. 3 ) {
            my $id;
            $clock{display}{canvas}{bulb}{$row}{$column} = $id =
              $clock{display}{canvas}->createOval(
                10 + 50 * $column,      10 + 50 * $row,
                10 + 45 + 50 * $column, 10 + 45 + 50 * $row,
                -outline    => $border,
                -activefill => $clock{setting}{color}
                  { $clock{setting}{brightness} },
                -state => q{disabled},
              );
        }
    }
}

$interface_row += 4;

$clock{control} =
  $clock{main}->Frame()
  ->grid( -column => 0, -columnspan => 4, -row => $interface_row, );

$interface_row = 0;  

$clock{control}->Label( -text => q{Binary mode:} )
  ->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{BCD},
    -value    => 0,
    -variable => \$clock{setting}{time_mode},
)->grid( -column => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{"True"},
    -value    => 1,
    -variable => \$clock{setting}{time_mode},
)->grid( -column => 3, -row => $interface_row, );

$interface_row++;

$clock{control}->Label( -text => q{Hour mode:} )
  ->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{24h},
    -value    => 0,
    -variable => \$clock{setting}{hour_mode},
)->grid( -column => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{12h},
    -value    => 1,
    -variable => \$clock{setting}{hour_mode},
)->grid( -column => 3, -row => $interface_row, );

$interface_row++;

$clock{control}->Label( -text => q{Brightness:} )
  ->grid( -column => 0, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{low},
    -value    => 0,
    -variable => \$clock{setting}{brightness},
)->grid( -column => 1, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{medium},
    -value    => 1,
    -variable => \$clock{setting}{brightness},
)->grid( -column => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{high},
    -value    => 2,
    -variable => \$clock{setting}{brightness},
)->grid( -column => 3, -row => $interface_row, );

$interface_row++;

$clock{control}->Label( -text => q{Outline:} )
  ->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{No},
    -value    => 0,
    -variable => \$clock{setting}{outline},
)->grid( -column => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{Yes},
    -value    => 1,
    -variable => \$clock{setting}{outline},
)->grid( -column => 3, -row => $interface_row, );

$interface_row++;

$clock{control}->Label( -text => q{Time display:} )
  ->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{Local},
    -value    => 0,
    -variable => \$clock{setting}{time_display},
)->grid( -column => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{GMT},
    -value    => 1,
    -variable => \$clock{setting}{time_display},
)->grid( -column => 3, -row => $interface_row, );

$interface_row++;

$clock{control}->Label( -text => q{Progress bar:} )
  ->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{No},
    -value    => 0,
    -variable => \$clock{setting}{show_progress_bar},
)->grid( -column => 2, -row => $interface_row, );
$clock{control}->Radiobutton(
    -text     => q{Yes},
    -value    => 1,
    -variable => \$clock{setting}{show_progress_bar},
)->grid( -column => 3, -row => $interface_row, );

$interface_row++;

if (0) {
    $clock{control}->Label( -text => q{Cheat mode:} )
      ->grid( -column => 0, -columnspan => 2, -row => $interface_row, );
    $clock{control}->Radiobutton(
        -text     => q{Off},
        -value    => 0,
        -variable => \$clock{setting}{cheat_mode},
    )->grid( -column => 2, -row => $interface_row, );
    $clock{control}->Radiobutton(
        -text     => q{On},
        -value    => 1,
        -variable => \$clock{setting}{cheat_mode},
    )->grid( -column => 3, -row => $interface_row, );
}

$clock{repeat} =
  $clock{display}{canvas}->repeat( 250, \&check_up );

MainLoop;

sub check_up {
    &check_outline;
    &check_brightness;
    &check_progress_bar;
    &check_time;
}

sub check_outline {
    foreach my $column ( 0 .. 5 ) {
        foreach my $row ( 0 .. 3 ) {
            $clock{display}{canvas}->itemconfigure(
                $clock{display}{canvas}{bulb}{$row}{$column},
                -outline => $clock{setting}{outline_color}
                  { $clock{setting}{outline} },
            );
        }
    }
}

sub check_brightness {
    foreach my $column ( 0 .. 5 ) {
        foreach my $row ( 0 .. 3 ) {
            $clock{display}{canvas}->itemconfigure(
                $clock{display}{canvas}{bulb}{$row}{$column},
                -disabledfill => $clock{setting}{color}
                  { $clock{setting}{brightness} },
            );
        }
    }
}

sub check_progress_bar {

    if ( $clock{setting}{show_progress_bar} != $clock{setting}{show_progress_bar_processed} ) {
        if ( $clock{setting}{show_progress_bar} == 0 ) {
            $clock{display}{progress_bar}->gridRemove();
        }
        elsif ( $clock{setting}{show_progress_bar} == 1 ) {
            $clock{display}{progress_bar}->grid(-column => 0, -columnspan => 4, -row => 2, );
        }
        $clock{setting}{show_progress_bar_processed} = $clock{setting}{show_progress_bar};
    }
}

sub check_time {
    &clear_time;
    if ( $clock{setting}{time_mode} ) {
        &check_time_true;
    }
    else {
        &check_time_bcd;
    }
}

sub get_hms {
    $clock{setting}{day_second} = time % 86400;
    my (
        $sec,  $min,  $hour, $mday, $mon,
        $year, $wday, $yday, $isdst
    ) = localtime;
    $clock{setting}{time} = substr( scalar localtime, 11, 8 );
    if ( $clock{setting}{time_display} ) {
        (
            $sec,  $min,  $hour, $mday, $mon,
            $year, $wday, $yday, $isdst
        ) = gmtime;
        $clock{setting}{time} = substr( scalar gmtime, 11, 8 );
    }
    $mon++;
    $year += 1900;

    $clock{setting}{day_second} =
      ( ( $hour * 60 ) + $min ) * 60 + $sec;
    $hour %= 12 if ( $clock{setting}{hour_mode} );

    return ( $hour, $min, $sec, 0 );
}

sub clear_time {
    foreach my $column ( 0 .. 5 ) {
        foreach my $row ( 0 .. 3 ) {
            $clock{display}{canvas}->itemconfigure(
                $clock{display}{canvas}{bulb}{$row}{$column},
                -state => q{normal}, );
        }
    }
}

sub check_time_bcd {
    my $tstr;
    {
        my @ts = map {
            my $s = sprintf q{%#04b}, $_;
            $s =~ s/^0B//;
            substr( q{0000} . $s, -4 );
          }
          split //,
          join( '', map { sprintf q{%02d}, $_; } get_hms() );

        if ($_debug) {
            print Data::Dumper->Dump( [ \@ts, ], [ qw( *ts ) ] ), qq{\n};
        }

        foreach my $column ( 0 .. 5 ) {
            foreach my $row ( 0 .. 3 ) {
                if ( substr( $ts[$column], $row, 1 ) eq q{1} ) {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}{$row}
                          {$column},
                        -state => q{disabled},
                    );
                }
                else {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}{$row}
                          {$column},
                        -state => q{normal},
                    );
                }
            }
        }
    }
}

sub check_time_true {
    my $tstr;
    {
        my @ts = map {
            my $s = sprintf q{%#06b}, $_;
            $s =~ s/^0B//;
            substr( q{000000} . $s, -6 );
        } get_hms();

        if ($_debug) {
            print Data::Dumper->Dump( [ \@ts, ], [ qw( *ts ) ] ), qq{\n};
        }

        foreach my $column ( 0 .. 5 ) {
            foreach my $row ( 0 .. 3 ) {
                if ( substr( $ts[$row], $column, 1 ) eq q{1} ) {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}
                          { $row + 1 }{$column},
                        -state => q{disabled}
                    );
                }
                else {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}
                          { $row + 1 }{$column},
                        -state => q{normal}
                    );
                }
            }
        }
    }
}

#
# Subroutines
#
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

=head1 tk_binary_clock-358181.pl

tk_binary_clock=358181.pl - a perl/Tk clock implementation of a binary clock

A representation of the L<Anelace "Powers of 2(R)" BCD Clock (via Anelace)|http://www.anelace.com/Crystal_Blue.html> (formerly L<http://www.thinkgeek.com/product/59e0/>).

=over

=item *
    My first perl/Tk clock program (so there are oddities, such as if you move your pointer over a "cell").

=item *
    Includes a binary display, time, and second of the day.

=item *
    Includes time as a progress bar (second of day), broken up into 24 hour
segments.

=item *
    Can display in 12 or 24 hour mode.

=item *
    Three (3) brightness levels.

=item *
    Optional "cell" outlining. (I have found the hardest thing about reading the physical clock (I own one-a gift from my SO) in the dark is seeing the empty cells.)

=item *
    Can display in "BCD" or "true" binary mode. ("BCD" - each digit is one column; "true" - hour, minute, and second are displayed as binary numbers on rows 2 through 4, in that order.) 

=item *
    Display updates approximately every 0.25s.

=back

=cut

