
object Main1 {
    
    val dim = 4
    val snake_short = List(
        5, 1, 1, 2, 1, 1, 1, 6, 1, 1, 2, 2, 4, 2, 3, 4, 3, 5, 5, 2, 2, 4, 2, 2, 2
    )
    val exit_after_first_solution = true
        
    val dimm1 = dim - 1
    val dimp1 = dim + 1
    val dimp2 = dim + 2
    val dimp2sq = dimp2 * dimp2
    val dimp2cb = dimp2 * dimp2 * dimp2
    
    val slen= dim * dim * dim

    def xyz2n(x: Int, y: Int, z: Int) = z * dimp2sq + y * dimp2 + x
    def n2x(n: Int) = n % dimp2
    def n2y(n: Int) = (n / dimp2) % dimp2
    def n2z(n: Int) = (n / dimp2sq) % dimp2

    var snake = List[Int]()

    def expand( list: List[Int], start: Int ): List[Int]= {
        def expand1( value: Int, n: Int ): List[Int] = {
            if (n == 0) Nil
            else value :: expand1( value, n-1 )
        }

        if (list == Nil) Nil
        else expand1( start, list.head ) ::: expand( list.tail, 3 - start)
    }   

    var offset: Int = 0
    var tries: Int = 0
 
    var result= new Array[Int](dimp2cb)
    var solved= new Array[Int](dimp2cb)

    def init = {
        for (z <- List.range(0, dimp2)) {
            for (y <- List.range(0, dimp2)) {
                for (x <- List.range(0, dimp2)) {
                    val n= xyz2n(x, y, z)
                    // println( List(x, y, z, n) )

                    if (x == 0 || y == 0 || z == 0
                        || x == dimp1 || y == dimp1 || z == dimp1
                    ) {
                        result(n)= -2
                        solved(n)= 0
                    }
                    else if (x == 1 || y == 1 || z == 1
                        || x == dim || y == dim || z == dim
                    ) {
                        result(n)= -1
                        solved(n)= (((x - 1) >> 1) + ((y - 1) >> 1) + ((z - 1) >> 1)) % 2 + 1
                    }
                    else {
                        result(n)= -1
                        solved(n)= 0
                    }
                }
            }
        }
    }

    def get_cube = {
        var r = "";

        for (z <- List.range(1, dimp1)) {

            r += ("z=" + z + "\n")
            r += "\t+----+----+----+----+"
            r += "\t+---+---+---+---+\n"
         
            for (y <- List.range(1, dimp1)) {
             
                r += "\t|"

                for (x <- List.range(1, dimp1)) {
                    val n= xyz2n(x, y, z)
                    // r += String.format(" %2d |", Array(result(n)))
                    r += " " + result(n) + " |"
                }

                r += "\t|"

                for (x <- List.range(1, dimp1)) {
                    val n= xyz2n(x, y, z)
                    r= r + " " + (if (snake(result(n)) == 1) "X" else " ") + " |"
                }

                r += "\n"
            }
            r += "\t+----+----+----+----+"
            r += "\t+---+---+---+---+\n"
        }
        r += "\n"
        r
    }

    def print_cube = {
        print( get_cube )
    }

    def print_solved {
        print( "\n\nSOLVED with " + tries + " tries\n" )
        print_cube
        
        if (exit_after_first_solution) System.exit(1)
    }
    
    def find_way(n: Int, idx: Int, dir: Int, fin: Boolean): Unit = {

        if (fin) {
            if (result(n) == 0) print_solved
        }
        else if (result(n) != -1) {
        }
        else if (solved(n) != 0 && solved(n) != snake(idx)) {
        }
        else {
            tries += 1;

            if (tries % 300000 == 0)
                println( "tries: " + tries + " (" + n2x(n) + "," + n2y(n) + "," + n2z(n) + ") -> idx: " + snake(idx))

            result(n)= idx;
            val newIdx = idx + 1
            val newFin= newIdx >= snake.length

            if (dir != 1) find_way(n + 1,       newIdx, 0, newFin)
            if (dir != 0) find_way(n - 1,       newIdx, 1, newFin)
            if (dir != 3) find_way(n + dimp2,   newIdx, 2, newFin)
            if (dir != 2) find_way(n - dimp2,   newIdx, 3, newFin)
            if (dir != 5) find_way(n + dimp2sq, newIdx, 4, newFin)
            if (dir != 4) find_way(n - dimp2sq, newIdx, 5, newFin)

            result(n)= -1
        }
    }
    
    def solve = {
        while (offset < slen) {
            if (offset > 0) {
                 snake= snake.tail ::: List(snake.head)
                 print( "\nstarting over (" + offset + ")\n" )
            }
            offset += 1
            find_way(xyz2n(1, 1, 1), 0, -1, false)
        }
    }
    
    def main(args: Array[String]): Unit = {
        snake= expand(snake_short, 1)
        init
        solve
    }
}
