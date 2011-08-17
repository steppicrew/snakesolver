#!perl6

use v6;

sub dont(&) {}

my $dim=4;
my @snake_short=<5 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2 2>;
# my @snake_short=<7 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2>;
# my @snake_short=<2 4 2 2 4 4 4 2 2 4 1 1 4 2 2 4 4 4 2 2 4 3 1>;

my $dimm1= $dim - 1;
my $dimp1= $dim + 1;
my $dimp2= $dim + 2;
my $dimp2sq= $dimp2 * $dimp2;

my $slen= $dim * $dim * $dim;

my $color= 2;
my @snake= @snake_short.map({ my $c= $color= 3 - $color; (^$_).map({ $c }); });

die "snake length is not $slen!" if $slen != @snake.elems;
die "snake length is uneven!" if @snake.elems ~& 1;


sub xyz2n($x, $y, $z) { $z * $dimp2sq + $y * $dimp2 + $x };
sub n2x($n) {  $n               % $dimp2 };
sub n2y($n) { ($n div $dimp2)   % $dimp2 };
sub n2z($n) { ($n div $dimp2sq) % $dimp2 };

sub getCube( @result ) {
    (1..$dim).map(sub ($z) {
        # z
        "\nz=$z\n" ~ (^$dimp1).map(sub ($y) {
            # y
            if $y == 0 || $y == $dimp1 {
                return "\t+----+----+----+----+\t+---+---+---+---+\n";
            }
            else {
                return "\t|" ~ (1..$dim).map(sub ($x) {
                    # x
                    my $n= xyz2n($x, $y, $z);
                    sprintf " %2d |", @result[$n];
                }).join('') ~ "\t|" ~ (1..$dim).map(sub ($x) {
                    # x
                    my $n= xyz2n($x, $y, $z);
                    if @snake[@result[$n]] == 2 {
                        " X |";
                    }
                    else {
                        "   |";
                    }
                }).join('') ~ "\n\t+----+----+----+----+\t+---+---+---+---+\n";
            }
        });
    });
};



my @result;
my @expected;

# prepare an empty cube with borders (@result) and define color of visible fronts (@expected)
for ^$dimp2 -> $x {
    for ^$dimp2 -> $y {
        for ^$dimp2 -> $z {
            my $n= xyz2n($x, $y, $z);
            if ($x, $y, $z).grep({ $_ == 0 || $_ == $dimp1 }) {
                # we are in outer space
                @result[$n]= -1;
                next;
            }
            if ($x, $y, $z).grep({ $_ == 1 || $_ == $dim }) {
                # we are at the surface
                @expected[$n]= ([+] ($x, $y, $z).map({ ($_ + 3) div 2 })) % 2 + 1;
                next;
            }
        }
    }
}

my $try= 0;

sub solve($n, $idx, @currentState is copy) {

    # return if new position is occupated already
    return if @currentState[$n];

    # return if special color is required but does not match
    return if @expected[$n] && @expected[$n] != @snake[$idx];

    @currentState[$n]= $idx;
    $try++;
    print "\r$try (" ~ n2x($n) ~ "," ~ n2y($n) ~ "," ~ n2z($n) ~ ") -> $idx: " ~ @snake[$idx] unless $try % 300;

    # we have solved it that way
    solved(@currentState) if $idx === @snake.elems;

    return (1, -1, $dimp2, -$dimp2, $dimp2sq, -$dimp2sq).map({ $n + $_ }).grep({ !@currentState[$_] }).map({ [$_, $idx + 1, [@currentState]] });
}

sub solved( @result ) {
    say "SOLVED! in $try tries";
    say getCube(@result);
}

for ^$slen {
    say;
    say "Starting over: $_";


    my @queue= ([xyz2n(1, 1, 1), 0, [@result]], );
    while @queue {
        @queue.unshift(solve(|@queue.shift));
    }

    @snake.push(@snake.shift);
}

