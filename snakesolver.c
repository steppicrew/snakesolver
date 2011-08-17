
// Compile with:
// gcc -std=c99 snakesolver.c && ./a.out

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define DIM 4
int snake_short[]= { 5, 1, 1, 2, 1, 1, 1, 6, 1, 1, 2, 2, 4, 2, 3, 4, 3, 5, 5, 2, 2, 4, 2, 2, 2, 0 };
// int snake_short="7 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2";
// int snake_short="2 4 2 2 4 4 4 2 2 4 1 1 4 2 2 4 4 4 2 2 4 3 1";
const int exit_after_first_solution= 1;

#define DIMM1 (DIM - 1)
#define DIMP1 (DIM + 1)
#define DIMP2 (DIM + 2)
#define DIMP2SQ (DIMP2 * DIMP2)
#define DIMP2CB (DIMP2 * DIMP2 * DIMP2)
#define SLEN (DIM * DIM * DIM)

#define xyz2n(x, y, z) (z * DIMP2SQ + y * DIMP2 + x )
#define n2x(n) (n % DIMP2)
#define n2y(n) ((n / DIMP2) % DIMP2)
#define n2z(n) ((n / DIMP2SQ) % DIMP2)

int result[DIMP2CB];
int solved[DIMP2CB];

int snake[SLEN];
int offset=0;
int tries= 0;

char *get_cube() {
    static char buf[10000];
    char *bufp= buf;

    for ( int z= 1; z <= DIM; z++ ) {
        bufp += sprintf(bufp, "z=%d\n"
            "\t+----+----+----+----+"
            "\t+---+---+---+---+\n", z);
        for ( int y= 1; y <= DIM; y++ ) {
            bufp += sprintf(bufp, "\t|");
            for ( int x= 1; x <= DIM; x++ ) {
                int n= xyz2n(x, y, z);
                bufp += sprintf(bufp, " %2d |", result[n]);
            }
            bufp += sprintf(bufp, "\t|");
            for ( int x= 1; x <= DIM; x++ ) {
                int n= xyz2n(x, y, z);
                int snake_i= result[n];
                if ( snake_i < 0 ) {
                    bufp += sprintf(bufp, " ? |");
                }
                else if ( snake[snake_i] == 1 ) {
                    bufp += sprintf(bufp, " X |");
                }
                else {
                    bufp += sprintf(bufp, " X |");
                }
            }
            bufp += sprintf(bufp, ""
                "\n\t+----+----+----+----+"
                "\t+---+---+---+---+\n");
        }
        bufp += sprintf(bufp, "\n");
    }

    return buf;
}

void print_cube() {
    puts(get_cube());
}


void has_solved() {
    printf("\n\nSOLVED with %d tries\n", tries);
    print_cube();
    if ( exit_after_first_solution ) {
        exit(1);
    }
}

void find_way( int n, int idx, int dir, int fin ) {

    if ( fin ) {
        if ( result[n] == 0 ) { // naechstes element ist der anfang der schlange
            has_solved();
        }
        return;
    }

//    printf("fin=%d idx=%d dir=%d n=%d result=%d solved=%d\n", fin, idx, dir, n, result[n], solved[n]);

    if ( result[n] > -2 ) return;
    if ( solved[n] > 0 && solved[n] != snake[idx] ) return; // color cares but does not match

//    printf("fin=%d idx=%d dir=%d n=%d\n", fin, idx, dir, n);

    tries++;
  
    if ( tries % 1000000 == 0 ) {
        printf("\rtries: %d (%d,%d,%d) -> idx: %d\n", tries, n2x(n), n2y(n), n2z(n), snake[idx]);
    }

    result[n]= idx++;

    fin= idx >= SLEN;

    if ( dir != 1 ) find_way(n + 1,       idx, 0, fin);
    if ( dir != 0 ) find_way(n - 1,       idx, 1, fin);
    if ( dir != 3 ) find_way(n + DIMP2,   idx, 2, fin);
    if ( dir != 2 ) find_way(n - DIMP2,   idx, 3, fin);
    if ( dir != 5 ) find_way(n + DIMP2SQ, idx, 4, fin);
    if ( dir != 4 ) find_way(n - DIMP2SQ, idx, 5, fin);

    result[n]= -2;
}

int main () {

    int color= 2;

    int j= 0;
    for ( int i= 0; snake_short[i]; i++ ) {
        color= 3 - color;
        while ( snake_short[i]-- ) snake[j++]= color;
    }

    assert( j == SLEN );
    assert( (j & 1) == 0 );

    for ( int x= 0; x <= DIMP1; x++ ) {
        for ( int y= 0; y <= DIMP1; y++ ) {
            for ( int z= 0; z <= DIMP1; z++ ) {
                int n= xyz2n(x, y, z);
                if ( x == 0 || y == 0 || z == 0
                    || x == DIMP1 || y == DIMP1 || z == DIMP1
                ) {
                    result[n]= -1;
                    solved[n]= 0;  // Unused
                }
                else if ( x == 1 || y == 1 || z == 1
                    || x == DIM || y == DIM || z == DIM
                ) {
                    result[n]= -2;
                    solved[n]= (((x - 1) >> 1) + ((y - 1) >> 1) + ((z - 1) >> 1)) % 2 + 1;
                }
                else {
                    result[n]= -2;
                    solved[n]= 0;
                }
            }
        }
    }

    while ( offset < SLEN ) {
        if ( offset ) {
            int last= snake[SLEN - 1];
            for ( int i= SLEN - 1; i > 0; i-- ) snake[i]= snake[i - 1];
            snake[0]= last;
            printf("\nstarting over (offset %d)\n", offset);
        }
        offset++;

        find_way(xyz2n(1, 1, 1), 0, -1, 0);
    }

    // print_cube();

    return 0;
}
