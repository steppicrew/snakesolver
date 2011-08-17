#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# our @result;
# do "snake_dumps.txt";
# print Dumper(scalar @result);

my $dim= 4;
my $snake_short= "5 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2 2";
# my $snake_short= "7 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2";
# my $snake_short= "2 4 2 2 4 4 4 2 2 4 1 1 4 2 2 4 4 4 2 2 4 3 1";
my $exit_after_first_solution= 1;

my $dimm1= $dim - 1;
my $dimp1= $dim + 1;
my $dimp2= $dim + 2;
my $dimp2sq= $dimp2 * $dimp2;
my $slen= $dim * $dim * $dim;

my @snake= ();
my $color= 2;
for my $i (split /\s+/, $snake_short) {
    $color= 3 - $color;
    for my $k (1..$i) {
        push @snake, $color;
    }
}

die "snake length is not $slen!" if $slen != scalar @snake;
die "snake length is uneven!" if scalar @snake & 1;

# print Dumper(@snake); die;

my $offset=0;
my $tries= 0;

my @result= ();
my @solved= ();

for my $x (0..$dimp1) {
    for my $y (0..$dimp1) {
        for my $z (0..$dimp1) {
            my $n= xyz2n($x, $y, $z);
            if ( $x == 0 || $y == 0 || $z == 0
                || $x == $dimp1 || $y == $dimp1 || $z == $dimp1
            ) {
                $result[$n]= -1;
                $solved[$n]= undef;  # Unused
                next;
            }
            if ( $x == 1 || $y == 1 || $z == 1
                || $x == $dim || $y == $dim || $z == $dim
            ) {
                $result[$n]= undef;
                $solved[$n]= ((($x - 1) >> 1) + (($y - 1) >> 1) + (($z - 1) >> 1)) % 2 + 1;
                next;
            }
            $result[$n]= undef;
            $solved[$n]= undef;
        }
    }
}

sub xyz2n { return $_[2] * $dimp2sq + $_[1] * $dimp2 + $_[0]; }
sub n2x { return $_[0]              % $dimp2; }
sub n2y { return ($_[0] / $dimp2)   % $dimp2; }
sub n2z { return ($_[0] / $dimp2sq) % $dimp2; }

# print_cube(); die;
# print Dumper(@solved); die;

sub get_cube {
    my $r= "";
    for my $z ( 1 .. $dim ) {
        $r .= "z=$z\n";
        $r .= "\t+----+----+----+----+";
        $r .= "\t+---+---+---+---+\n";
        for my $y ( 1 .. $dim ) {
            $r .= "\t|";
            for my $x ( 1 .. $dim ) {
                my $n= xyz2n($x, $y, $z);
                $r .= sprintf(" %2d |", $result[$n]);
            }
            $r .= "\t|";
            for my $x ( 1 .. $dim ) {
                my $n= xyz2n($x, $y, $z);
                $r .= " " . ($snake[$result[$n]] == 1 ? "X" : " ") . " |";
            }
            $r .= "\n\t+----+----+----+----+";
            $r .= "\t+---+---+---+---+\n";
        }
        $r .= "\n";
    }
    return $r;
}

sub print_cube {
    print get_cube;
}

sub get_snake_short {
    my $r= '';
    my @snake2= (@snake);
    while (@snake2) {
        my $n= 0;
        while ( @snake2 && $snake2[0] == 1 ) { shift @snake2; $n++; }
        $r .= " $n" if $n;
        $n= 0;
        while ( @snake2 && $snake2[0] == 2 ) { shift @snake2; $n++; }
        $r .= " $n" if $n;
    }
    $r =~ s/^ //;
    return $r;
}

sub solved {
    print "\n\nSOLVED with $tries tries\n";
    print_cube;

    my $file= 'snake_dumps.txt';
    my $fout;
    if ( open ($fout, ">>$file") ) {
        my $d= Data::Dumper->new([{ snake => \@snake, result => \@result }], ["a= push \@result, \$a"]);
        $d->Indent(0);
        print $fout $d->Dump(), "\n";
        close $fout;
    }

    $file= 'snake_cubes.txt';
    if ( open ($fout, ">>$file") ) {
        print $fout get_snake_short, "\n";
        print $fout get_cube;
        close $fout;
    }

    exit(1) if $exit_after_first_solution;
}

sub find_way {
    my ($n, $idx, $dir, $fin)= @_;
  
    if ( $fin ) {
        solved if $result[$n] == 0; # naechstes element ist der anfang der schlange
        return;
    }

    return if defined $result[$n]; # already set
    return if defined $solved[$n] && $solved[$n] != $snake[$idx]; # color cares but does not match

    # print "fin=$fin idx=$idx dir=$dir n=$n xyz=[$x $y $z]\n";
    # my $dummy = <STDIN>;
  
    $tries++;
  
    print "\rtries: $tries (" . n2x($n) . "," . n2y($n) . "," . n2z($n) . ") -> $idx: " . $snake[$idx] unless $tries % 300;

    $result[$n]= $idx++;

    $fin= $idx >= scalar @snake;

    find_way($n + 1,        $idx, 0, $fin) unless $dir == 1;
    find_way($n - 1,        $idx, 1, $fin) unless $dir == 0;
    find_way($n + $dimp2,   $idx, 2, $fin) unless $dir == 3;
    find_way($n - $dimp2,   $idx, 3, $fin) unless $dir == 2;
    find_way($n + $dimp2sq, $idx, 4, $fin) unless $dir == 5;
    find_way($n - $dimp2sq, $idx, 5, $fin) unless $dir == 4;

    $result[$n]= undef;
}

while ( $offset < $slen ) {
    if ( $offset ) {
        push @snake, shift @snake;
        print "\nstarting over ($offset)\n";
    }
    $offset++;
  
    find_way(xyz2n(1, 1, 1), 0, -1, 0);
}
