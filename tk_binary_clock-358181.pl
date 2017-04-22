#!/usr/bin/perl

# http://www.thinkgeek.com/product/59e0/

use strict;
use warnings;

use vars qw( %clock );

use Data::Dumper;
use Tk;
use Tk::ProgressBar;

$| = 1;
srand();
$Data::Dumper::Sortkeys = 1;

$clock{setting}{time_mode}  = 0;
$clock{setting}{hour_mode}  = 0;
$clock{setting}{brightness} = 2;
$clock{setting}{cheat_mode} = 1;
$clock{setting}{color}{0}   = q{#008};
$clock{setting}{color}{1}   = q{#00C};
$clock{setting}{color}{2}   = q{#00F};
$clock{setting}{time}       = q{00:00:00};
$clock{setting}{day_second} = 0;

$clock{main} = new MainWindow;

$clock{display} =
  $clock{main}->Frame()
  ->grid( -column => 0, -columnspan => 4, -row => 0, );
$clock{display}{canvas} =
  $clock{display}->Canvas( -height => 240, -width => 320, )
  ->grid( -column => 0, -columnspan => 4, -row => 0, );
$clock{display}{label} = $clock{display}->Label(
    -textvariable => \$clock{setting}{time},
    -state        => q{normal},
)->grid( -column => 0, -columnspan => 2, -row => 1, );
$clock{display}{label2} = $clock{display}->Label(
    -textvariable => \$clock{setting}{day_second},
    -state        => q{normal},
)->grid( -column => 2, -columnspan => 2, -row => 1, );
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
)->grid( -column => 0, -columnspan => 4, -row => 2, );

{
    my $active   = q{#3333FF};
    my $disabled = q{#000099};
    my $border   = q{#000066};
    my $empty    = q{#000000};
    $clock{display}{canvas}{bg} =
      $clock{display}{canvas}
      ->createRectangle( 0, 0, 320, 240, -fill => q{#000000}, );
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

$clock{control} =
  $clock{main}->Frame()
  ->grid( -column => 0, -columnspan => 4, -row => 6, );

$clock{control}->Label( -text => q{Binary mode:} )
  ->grid( -column => 0, -columnspan => 2, -row => 0, );
$clock{control}->Radiobutton(
    -text     => q{BCD},
    -value    => 0,
    -variable => \$clock{setting}{time_mode},
)->grid( -column => 2, -row => 0, );
$clock{control}->Radiobutton(
    -text     => q{"True"},
    -value    => 1,
    -variable => \$clock{setting}{time_mode},
)->grid( -column => 3, -row => 0, );

$clock{control}->Label( -text => q{Hour mode:} )
  ->grid( -column => 0, -columnspan => 2, -row => 1, );
$clock{control}->Radiobutton(
    -text     => q{24h},
    -value    => 0,
    -variable => \$clock{setting}{hour_mode},
)->grid( -column => 2, -row => 1, );
$clock{control}->Radiobutton(
    -text     => q{12h},
    -value    => 1,
    -variable => \$clock{setting}{hour_mode},
)->grid( -column => 3, -row => 1, );

$clock{control}->Label( -text => q{Brightness:} )
  ->grid( -column => 0, -row => 2, );
$clock{control}->Radiobutton(
    -text     => q{low},
    -value    => 0,
    -variable => \$clock{setting}{brightness},
)->grid( -column => 1, -row => 2, );
$clock{control}->Radiobutton(
    -text     => q{medium},
    -value    => 1,
    -variable => \$clock{setting}{brightness},
)->grid( -column => 2, -row => 2, );
$clock{control}->Radiobutton(
    -text     => q{high},
    -value    => 2,
    -variable => \$clock{setting}{brightness},
)->grid( -column => 3, -row => 2, );

if (0) {
    $clock{control}->Label( -text => q{Cheat mode:} )
      ->grid( -column => 0, -columnspan => 2, -row => 3, );
    $clock{control}->Radiobutton(
        -text     => q{Off},
        -value    => 0,
        -variable => \$clock{setting}{cheat_mode},
    )->grid( -column => 2, -row => 3, );
    $clock{control}->Radiobutton(
        -text     => q{On},
        -value    => 1,
        -variable => \$clock{setting}{cheat_mode},
    )->grid( -column => 3, -row => 3, );
}

$clock{repeat} =
  $clock{display}{canvas}->repeat( 500, \&check_up );

MainLoop;

sub check_up {
    &check_brightness;
    &check_time;
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
    $mon++;
    $year += 1900;
    $clock{setting}{time} = substr( scalar localtime, 11, 8 );

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
            my $s = sprintf q{%#04B}, $_;
            $s =~ s/^0B//;
            substr( q{0000} . $s, -4 );
          }
          split //,
          join( '', map { sprintf q{%02d}, $_; } get_hms() );

        foreach my $column ( 0 .. 5 ) {
            foreach my $row ( 0 .. 3 ) {
                if ( substr( $ts[$column], $row, 1 ) eq q{0} ) {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}{$row}
                          {$column},
                        -state => q{normal},
                    );
                }
                else {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}{$row}
                          {$column},
                        -state => q{disabled},
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
            my $s = sprintf q{%#06B}, $_;
            $s =~ s/^0B//;
            substr( q{000000} . $s, -6 );
        } get_hms();

        foreach my $column ( 0 .. 5 ) {
            foreach my $row ( 0 .. 3 ) {
                if ( substr( $ts[$row], $column, 1 ) eq q{0} ) {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}
                          { $row + 1 }{$column},
                        -state => q{normal}
                    );
                }
                else {
                    $clock{display}{canvas}->itemconfigure(
                        $clock{display}{canvas}{bulb}
                          { $row + 1 }{$column},
                        -state => q{disabled}
                    );
                }
            }
        }
    }
}

__END__

