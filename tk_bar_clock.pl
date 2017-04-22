#!/usr/bin/perl

# https://www.thinkgeek.com/product/jhig/

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

$clock{setting}{time_mode}        = 0;
$clock{setting}{hour_mode}        = 0;
$clock{setting}{brightness}       = 2;
$clock{setting}{outline}          = 1;
$clock{setting}{cheat_mode}       = 1;
$clock{setting}{color}{0}         = q{#008};
$clock{setting}{color}{1}         = q{#00C};
$clock{setting}{color}{2}         = q{#00F};
$clock{setting}{outline_color}{0} = q{#000};
$clock{setting}{outline_color}{1} = q{#008};
$clock{setting}{time}             = q{00:00:00};
$clock{setting}{day_second}       = 0;

$clock{main} = new MainWindow;

$clock{display} =
  $clock{main}->Frame()
  ->grid( -column => 0, -columnspan => 4, -row => 0, );
$clock{display}{label} = $clock{display}->Label(
    -textvariable => \$clock{setting}{time},
    -state        => q{normal},
)->grid( -column => 0, -columnspan => 2, -row => 1, );
$clock{display}{label2} = $clock{display}->Label(
    -textvariable => \$clock{setting}{day_second},
    -state        => q{normal},
)->grid( -column => 2, -columnspan => 2, -row => 1, );

$clock{display}{progress_bar}{day} = $clock{display}->ProgressBar(
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

$clock{display}{label} = $clock{display}->Label(
    -text => q{Hour:},
    -state        => q{normal},
)->grid( -column => 0, -columnspan => 2, -row => 3, );

$clock{display}{progress_bar}{hour_24} = $clock{display}->ProgressBar(
    -width  => 20,
    -length => 320,
    -anchor => q{w},
    -from   => 0,
    -to     => 24,
    -blocks => 24,
    -colors => [
         0,   'blue',  6, 'green',
        12, 'yellow', 18, 'red',
    ],
    -variable => \$clock{setting}{hour_24},
)->grid( -column => 0, -columnspan => 4, -row => 4, );
$clock{display}{progress_bar}{hour_12} = $clock{display}->ProgressBar(
    -width  => 20,
    -length => 320,
    -anchor => q{w},
    -from   => 1,
    -to     => 12,
    -blocks => 12,
    -colors => [
         1, 'blue',   3, 'green',
         6, 'yellow', 9, 'red',
    ],
    -variable => \$clock{setting}{hour_12},
)->grid( -column => 0, -columnspan => 4, -row => 4, );

$clock{display}{progress_bar}{hour_12}->gridForget();


$clock{display}{label} = $clock{display}->Label(
    -text => q{Minute:},
    -state        => q{normal},
)->grid( -column => 0, -columnspan => 2, -row => 5, );

$clock{display}{progress_bar}{minute} = $clock{display}->ProgressBar(
    -width  => 20,
    -length => 320,
    -anchor => q{w},
    -from   => 0,
    -to     => 60,
    -blocks => 61,
    -colors => [
         0,     'blue',   15, 'green',
        30, 'yellow',     45, 'red',
    ],
    -variable => \$clock{setting}{minute},
)->grid( -column => 0, -columnspan => 4, -row => 6, );



$clock{control} =
  $clock{main}->Frame()
  ->grid( -column => 0, -columnspan => 4, -row => 6, );

$clock{control}->Label( -text => q{Hour mode:} )
  ->grid( -column => 0, -columnspan => 2, -row => 2, );
$clock{control}->Radiobutton(
    -text     => q{24h},
    -value    => 0,
    -variable => \$clock{setting}{hour_mode},
)->grid( -column => 2, -row => 2, );
$clock{control}->Radiobutton(
    -text     => q{12h},
    -value    => 1,
    -variable => \$clock{setting}{hour_mode},
)->grid( -column => 3, -row => 2, );

if (0) {
    $clock{control}->Label( -text => q{Cheat mode:} )
      ->grid( -column => 0, -columnspan => 2, -row => 4, );
    $clock{control}->Radiobutton(
        -text     => q{Off},
        -value    => 0,
        -variable => \$clock{setting}{cheat_mode},
    )->grid( -column => 2, -row => 5, );
    $clock{control}->Radiobutton(
        -text     => q{On},
        -value    => 1,
        -variable => \$clock{setting}{cheat_mode},
    )->grid( -column => 3, -row => 5, );
}

$clock{repeat} =
  $clock{display}->repeat( 250, \&check_up );

MainLoop;

sub check_up {
    my @foo = get_hms();

    if ( $clock{setting}{hour_mode} ) {
        $clock{display}{progress_bar}{hour_24}->gridForget();
        $clock{display}{progress_bar}{hour_12}->grid( -column => 0, -columnspan => 4, -row => 4, );
    }
    else {
        $clock{display}{progress_bar}{hour_12}->gridForget();
        $clock{display}{progress_bar}{hour_24}->grid( -column => 0, -columnspan => 4, -row => 4, );
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
    $clock{setting}{hour_24} = $hour;
    $clock{setting}{hour_12} = $hour % 12;
    if ( $clock{setting}{hour_12} == 0 ) {
        $clock{setting}{hour_12} = 12;
    }
    $clock{setting}{minute} = $min;
    if ( $clock{setting}{hour_mode} ) {
		my $hour_12 = $hour % 12;
		if ( $hour_12 == 0 ) {
			$hour_12 = 12;
		}
		$clock{setting}{time} = sprintf qq{%02d:%02d:%02d%1sM}, $hour_12, $min, $sec, ( $hour >= 12 ? q{P} : q{A} );
	}

    return ( $hour, $min, $sec, 0 );
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

=head1 tk_bar_clock.pl

tk_bar_clock.pl - a perl/Tk clock implemented via progress bars

A representation of L<The Luminous Electronic Bargraph Clock (via ThinkGeek)|https://www.thinkgeek.com/product/jhig/>.

=over

=item *
    Includes time as a progress bar (second of day), broken up into 24 hour
segments.

=item *
    Includes hour and minute as progress bars.

=item *
    Can display in 12 or 24 hour mode.

=item *
    Display updates approximately every 0.25s.

=back

=cut

