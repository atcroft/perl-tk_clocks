#!/usr/bin/perl

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
    x => 480,
    y => 500,
);

GetOptions( qq{debug} => \$_debug, );


$obj{mw} = Tk::MainWindow->new();
$obj{canvas} =
  $obj{mw}
  ->Canvas( -width => $max{x}, -height => $max{y}, -background => q{#000000}, )
  ->pack();
$obj{image} = $obj{mw}
  ->Photo( -width => $max{x}, -height => $max{y}, -palette => q{256/256/256}, );
$obj{image}->blank;
$obj{canvas}->createImage( 0, 0, -image => $obj{image}, -anchor => q{nw}, );

$obj{canvas}->after( 1250, \&update );

$obj{repeat} = $obj{canvas}->repeat( 250, \&update );

MainLoop;

#
# Subroutines
#
sub update {

    my $_pi      = 3.141593;
    my $mode_24h = 0;
    my %color    = (

        # hand => q{#00FFFF},
        face => q{#009999},
    );

    my %center;
    foreach my $c ( keys %max ) {
        $center{$c} = $max{$c} / 2;
    }
    my $radius = $max{x};
    if ( $max{y} < $radius ) {
        $radius = $max{y} / 2;
    }
    $radius = int( $radius * 0.375 );

    # print Data::Dumper->Dump( [ \$radius, ], [ qw( *radius ) ] ), qq{\n};

    #    0     1     2      3      4     5      6      7      8
    # ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
    #                                                           localtime(time);

    my @lt      = localtime(time);
    my $seconds = $lt[2] * 3600;
    $seconds += $lt[1] * 60;
    $seconds += $lt[0];

    # print __FILE__ . q{:} . __LINE__ . q{: } . qq{\n};

    $obj{canvas}
      ->createRectangle( 0, 0, $max{x}, $max{y}, -fill => q{#000000}, );

    # Draw face
    $obj{canvas}->createOval(
        $center{x} - 5,
        $center{y} - 5,
        $center{x} + 5,
        $center{y} + 5,
        -fill => $color{hand},
    );
    foreach my $i ( 0 .. 95 ) {
        my %inner;
        my %outer;
        my $width;
        if ( $i % 4 == 0 ) {
            $inner{radius} = $radius + 20;
            $outer{radius} = $radius + 28;
            $width         = 2;
        }
        else {
            $inner{radius} = $radius + 20;
            $outer{radius} = $radius + 24;
            $width         = 1;
        }
        $outer{angle} = $inner{angle} = $_pi * ( $i / 48 );
        $inner{x} = $center{x} + int( $inner{radius} * cos( $inner{angle} ) );
        $inner{y} = $center{y} - int( $inner{radius} * sin( $inner{angle} ) );
        $outer{x} = $center{x} + int( $outer{radius} * cos( $outer{angle} ) );
        $outer{y} = $center{y} - int( $outer{radius} * sin( $outer{angle} ) );
        $obj{canvas}->createLine(
            $inner{x}, $inner{y}, $outer{x}, $outer{y},
            -fill  => $color{face},
            -state => q{normal},
            -width => $width,
        );

# print Data::Dumper->Dump( [ \%max, \$radius, \$i, \%inner, \%outer, ], [ qw( *max *radius *i *inner *outer ) ] ), qq{\n};
    }
    foreach my $i ( 1 .. ( $mode_24h ? 24 : 12 ) ) {
        my %cp;
        $cp{radius} = $radius + 40;
        # $cp{angle}  = $_pi * ( ( 24 - $i - 6 ) / 12 );
        if ( $mode_24h ) {
            $cp{angle} = $_pi * ( ( 6 - $i ) / 12 );
        }
        else {
            $cp{angle} = $_pi * ( ( 3 - $i ) / 6 );
        }
        $cp{x} = $center{x} + int( $cp{radius} * cos( $cp{angle} ) );
        $cp{y} = $center{y} - int( $cp{radius} * sin( $cp{angle} ) );
        $obj{canvas}->createText(
            $cp{x}, $cp{y},
            -anchor => q{center},
            -fill   => $color{face},
            -state  => q{normal},
            -text   => sprintf( qq{%02d}, $i % ( $mode_24h ? 24 : 13 ) ),
        );
    }

    {
        my %inner;
        my %outer;

        $inner{hour}{radius}   = int( $radius * ( 3.0 / 6.0 ) );
        $inner{minute}{radius} = $outer{hour}{radius} =   int( $radius * ( 2.0 / 6.0 ) );
        $inner{second}{radius} = $outer{minute}{radius} = int( $radius * ( 1.0 / 6.0 ) );
        $outer{second}{radius} = $radius;
        $color{hand}{hour}     = q{#00FF00};
        $color{hand}{minute}   = q{#0000FF};
        $color{hand}{second}   = q{#FF0000};
        $obj{canvas}->createOval( $center{x} - 5, $center{y} - 5, $center{x} + 5, $center{y} + 5, -fill => $color{hand}{hour}, );
        foreach my $str (qw/ hour minute second /) {
            my $angle;
                # =MOD( INT( 90 - 360 * ( D2 / 24 ) ), 360 )
                if ( $mode_24h ) {
                    $angle = $_pi * ( int( 90 - 360 * ( ( $lt[2] % 24 )/ 24.0 ) ) % 360 ) / 180.0;
                }
                else {
                    $angle = $_pi * ( int( 90 - 360 * ( ( $lt[2] % 12 )/ 12.0 ) ) % 360 ) / 180.0;
                }
            $inner{x} = $center{x};
            $inner{y} = $center{y};
            if ( $str eq q{minute} ) {
                # =MOD( INT( 90 - 360 * ( D2 / 60 ) ), 360 )
                $angle = $_pi * ( int( 90 - 360 * ( $lt[1] / 60.0 ) ) % 360 ) / 180.0;
                $inner{x} = $outer{x};
                $inner{y} = $outer{y};
            }
            if ( $str eq q{second} ) {
                # =MOD( INT( 90 - 360 * ( D2 / 60 ) ), 360 )
                $angle = $_pi * ( int( 90 - 360 * ( $lt[0] / 60.0 ) ) % 360 ) / 180.0;
                $inner{x} = $outer{x};
                $inner{y} = $outer{y};
            }
            $outer{x} = $inner{x} + int( $inner{$str}{radius} * cos($angle) );
            $outer{y} = $inner{y} - int( $inner{$str}{radius} * sin($angle) );
            if ( $str ne q{hour} ) {
                $obj{canvas}->createOval(
                    $inner{x} - 3,
                    $inner{y} - 3,
                    $inner{x} + 3,
                    $inner{y} + 3,
                    -fill => $color{hand}{$str},
                );
            }
            $obj{canvas}->createLine(
                $inner{x}, $inner{y}, $outer{x}, $outer{y},
                -fill  => $color{hand}{$str},
                -state => q{normal},
                -width => 2,
            );
        }
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

