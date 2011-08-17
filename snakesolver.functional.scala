object Main {

    val dim = 4
    val snake_short = List(
        (5, 1), (1, 2), (1, 1), (1, 6), (1, 1), (2, 2), (4, 2), (3, 4), (3, 5), (5, 2), (2, 4), (2, 2), (2, 0)
    )
    val exit_after_first_solution = true

    val dimp1 = dim + 1

    def buildSnake(snake: List[Tuple2[Int, Int]]):List[Int]=
        if (snake.isEmpty) Nil
        else (0 until snake.head._1).map(_ => 1).toList ::: (0 until snake.head._2).map(_ => 2).toList ::: buildSnake(snake.tail)

    val snake = buildSnake(snake_short)

    val visited= (0 to dimp1).map(
        x => (0 to dimp1).map(
            y => (0 to dimp1).map(
                z => (x, y, z)
            )
        ).reduce((a, b) => a ++ b)
    ).reduce((a, b) => a ++ b).filter(
        xyz => xyz._1 == 0 || xyz._1 == dimp1 || xyz._2 == 0 || xyz._2 == dimp1 || xyz._3 == 0 || xyz._3 == dimp1
    ).toSet

    val expected= (0 to dimp1).map(
        x => (0 to dimp1).map(
            y => (0 to dimp1).map(
                z => if (List(x, y, z).exists( i => i == 1 || i == dim)) List(x, y, z).map( i => (i + 3) / 2 ).reduce( (a, b) => a + b ) % 2 + 1 else 0
            )
        )
    )

    var tries = 0

    def get_cube(result: Seq[Seq[Seq[Int]]]) = {
        (1 to dim).map( z =>
            "z=" + z + "\n" +
            "\t+----+----+----+----+\t+---+---+---+---+\n" +

            (1 to dim).map( y =>
                "\t|" +

                (1 to dim).map( x =>
                    " %2d |".format(result(x)(y)(z))
                ).reduce( (a, b) => a + b) +

                "\t|" +

                (1 to dim).map( x =>
                    " " +
                    (if (result(x)(y)(z) < 0) "?" else if (snake(result(x)(y)(z)) == 1) "X" else " ") +
                    " |"
                ).reduce( (a, b) => a + b) +
                "\n\t+----+----+----+----+\t+---+---+---+---+\n"
            ).reduce( (a, b) => a + b)
        ).reduce( (a, b) => a + b) +
        "\n"
    }

    def print_solved(positions: Seq[Tuple3[Int,Int,Int]]) {
        print( "\n\nSOLVED with " + tries + " tries\n" )
        print( get_cube(
            (0 to dimp1).map(
                x => (0 to dimp1).map(
                    y => (0 to dimp1).map(
                        z => positions.indexOf((x, y, z))
                    )
                )
            )
        ) )

        if (exit_after_first_solution) System.exit(1)
    }

    def solve(positions: Seq[Tuple3[Int, Int, Int]], visited: Set[Tuple3[Int, Int, Int]]): Unit = {

        val xyz= positions.last

        if (positions.length == snake.length) {
//            print("Positions: " + positions + "\n")
//            print("Visited: " + visited + "\n")
            print_solved(positions)
            return
        }

        val expect= expected(xyz._1)(xyz._2)(xyz._3)
        if (expect != 0 && expect != snake(positions.length - 1)) {
//            print("color doesn't match: " + expect + " vs " + snake(positions.length - 1) + " at " + positions.length + "\n")
            return
        }

        tries += 1;
        if (tries % 300000 == 0) {
            println( "tries: " + tries + " " + xyz + " -> idx: " + positions.length + " (" + snake(positions.length) + ")")
        }

        Seq((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)).
            map(add => ( xyz._1 + add._1, xyz._2 + add._2, xyz._3 + add._3) ).
            filter( xyz => !visited.contains(xyz) ).
            map( xyz => solve(positions :+ xyz, visited + xyz) )
    }

    def main(args: Array[String]): Unit = {
        (1 to dim).map(
            x => (1 to dim).map(
                y => (1 to dim).map(
                    z => {
                        val xyz= (x, y, z)
                        print("Starting at " + xyz + "\n")
                        solve(Seq(xyz), visited + xyz)
                    }
                )
            )
        )
    }

}

