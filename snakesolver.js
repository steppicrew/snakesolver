#!/home/raisin/nodejs/bin/node

var dim= 4
var snake_short= "5 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2 2"
// var snake_short="7 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2"
// var snake_short="2 4 2 2 4 4 4 2 2 4 1 1 4 2 2 4 4 4 2 2 4 3 1"
var exit_after_first_solution= 1

var dimm1= dim - 1
var dimp1= dim + 1
var dimp2= dim + 2
var dimp2sq= dimp2 * dimp2
var slen= dim * dim * dim

var snake= []
var color= 2
var snake_shorts= snake_short.split(/\s+/)
for ( var i in snake_shorts ) {
    color= 3 - color
    for ( var j= snake_shorts[i]; j > 0; j-- ) {
        snake.push(color)
    }
}

if ( slen != snake.length ) {
    console.error("snake length is not slen!")
    die()
}
if ( snake.length & 1 ) {
    console.error("snake length is uneven!")
    die()
}

var offset=0
var tries= 0

var xyz2n= function(x, y, z) { return z * dimp2sq + y * dimp2 + x }
var n2x= function(n) { return n % dimp2 }
var n2y= function(n) { return Math.floor(n / dimp2) % dimp2 }
var n2z= function(n) { return Math.floor(n / dimp2sq) % dimp2 }

var result= []
var solved= []

for ( var x= 0; x <= dimp1; x++ ) {
    for ( var y= 0; y <= dimp1; y++ ) {
        for ( var z= 0; z <= dimp1; z++ ) {
            var n= xyz2n(x, y, z)
            if ( x == 0 || y == 0 || z == 0
                || x == dimp1 || y == dimp1 || z == dimp1
            ) {
                result[n]= -1
                solved[n]= undefined;  // Unused
            }
            else if ( x == 1 || y == 1 || z == 1
                || x == dim || y == dim || z == dim
            ) {
                result[n]= undefined
                solved[n]= (((x - 1) >> 1) + ((y - 1) >> 1) + ((z - 1) >> 1)) % 2 + 1
            }
            else {
                result[n]= undefined
                solved[n]= undefined
            }
        }
    }
}

var get_cube = function() {
    var r= ""
    for ( var z= 1; z <= dim; z++ ) {
        r += "z=z\n"
        r += "\t+----+----+----+----+"
        r += "\t+---+---+---+---+\n"
        for ( var y= 1; y <= dim; y++ ) {
            r += "\t|"
            for ( var x= 1; x <= dim; x++ ) {
                var n= xyz2n(x, y, z)
                r += " " + (result[n] !== undefined ? result[n] : "??") + " |"
            }
            r += "\t|"
            for ( var x= 1; x <= dim; x++ ) {
                var n= xyz2n(x, y, z)
                r += " " + (snake[result[n]] == 1 ? "X" : " ") + " |"
            }
            r += "\n\t+----+----+----+----+"
            r += "\t+---+---+---+---+\n"
        }
        r += "\n"
    }
    return r
}

var print_cube= function() {
    console.log(get_cube())
}

//print_cube();
//console.log(solved)

var has_solved= function() {
    console.log("\n\nSOLVED with " + tries + " tries")
    print_cube()
    if ( exit_after_first_solution ) {
        process.exit(1)
    }
}

var find_way= function( n, idx, dir, fin ) {

    if ( fin ) {
        if ( result[n] === 0 ) { // naechstes element ist der anfang der schlange
            has_solved()
        }
        return
    }

    if ( result[n] !== undefined ) return
    if ( solved[n] !== undefined && solved[n] != snake[idx] ) return // color cares but does not match

// console.log("fin=" + fin + " idx=" + idx + " dir=" + dir + " n=" + n)

    tries++
  
    if ( tries % 1000000 == 0 ) {
        console.log("\rtries: " + tries + " (" + n2x(n) + "," + n2y(n) + "," + n2z(n) + ") -> idx: " + snake[idx])
    }

    result[n]= idx++

    fin= idx >= snake.length

    if ( dir != 1 ) find_way(n + 1,       idx, 0, fin)
    if ( dir != 0 ) find_way(n - 1,       idx, 1, fin)
    if ( dir != 3 ) find_way(n + dimp2,   idx, 2, fin)
    if ( dir != 2 ) find_way(n - dimp2,   idx, 3, fin)
    if ( dir != 5 ) find_way(n + dimp2sq, idx, 4, fin)
    if ( dir != 4 ) find_way(n - dimp2sq, idx, 5, fin)

    result[n]= undefined
}

while ( offset < slen ) {
    if ( offset ) {
        snake.push(snake.shift())
        console.log("\nstarting over (offset)")
    }
    offset++
  
    find_way(xyz2n(1, 1, 1), 0, -1, false)
}
