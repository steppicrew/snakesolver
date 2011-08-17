#!/usr/bin/python

dim= 4
snake_short= [(5, 1), (1, 2), (1, 1), (1, 6), (1, 1), (2, 2), (4, 2), (3, 4), (3, 5), (5, 2), (2, 4), (2, 2), (2, 0)]
exit_after_first_solution= True

dimp1= dim + 1
dimp2= dim + 2
dimp2sq= dimp2 * dimp2
slen= dim * dim * dim

add= lambda a, b: a + b

snake= reduce(
    add,
    [
        [ 1 for x in range( s[0] ) ] + [ 2 for x in range( s[1] ) ] for s in snake_short
    ]
)

result= [
    [
        [
            -1 if len(filter(lambda _: _ == 0 or _ == dimp1, [x, y, z])) > 0 else 0 for z in range(dimp2) 
        ] for y in range(dimp2) 
    ] for x in range(dimp2)
]

expected= [
    [
        [
            reduce(
                add,
                map(lambda a: (a + 3) // 2, [x, y, z])
            ) % 2 + 1 if len(filter(lambda _: _ == 1 or _ == dim, [x, y, z])) > 0 else 0 for z in range(dimp2) 
        ] for y in range(dimp2)
    ] for x in range(dimp2)
]

if len(snake) != slen:
    print "Snake has length", len(snake), "but should have length", slen, "."
    sys.exit


tries= 0

def solveSnake(snake):
    def getCube(result):

        def getXresult(x, y, z):
            return ' {:2d} |'.format(result[x][y][z])

        def getXindex(x, y, z):
            return ' ' + ('X' if snake[result[x][y][z]] == 1 else ' ') + ' |'

        def getY(y, z):
            return '\t|' + reduce(
                add, [getXresult(x, y, z) for x in range(1, dimp1)]
            ) + '\t|' + reduce(
                add, [getXindex(x, y, z) for x in range(1, dimp1)]
            ) + '\n\t+' + reduce(
                add, ['----+' for x in range(1, dimp1)]
            ) + '\t+' + reduce(
                add, ['---+' for x in range(1, dimp1)]
            ) +'\n'

        def getZ(z):
            return '\nz= ' + str(z) + '\n\t+' + reduce(
                add, ['----+' for x in range(1, dimp1)]
            ) + '\t+' + reduce(
                add, ['---+' for x in range(1, dimp1)]
            ) + '\n' + reduce(
                add, [getY(y, z) for y in range(1, dimp1)]
            ) + '\n'

        return reduce(add, [getZ(z) for z in range(1, dimp1)])


    def solve(xyz, idx, currentState):

        if idx == slen:
            solved(currentState)
            return
#        print xyz, idx, snake[idx]

        getValueAt= lambda l, xyz: l[xyz[0]][xyz[1]][xyz[2]]
        getCurrentState= lambda xyz: getValueAt(currentState, xyz)
        addXyz= lambda add: [ _[0] + _[1] for _ in zip(xyz, add)]

        if getCurrentState(xyz) != 0:
#            print "->", getCurrentState(xyz)
            return

        if not getValueAt(expected, xyz) in set((0, snake[idx])):
#            print "=>", getValueAt(expected, xyz), snake[idx]
            return

        currentState[xyz[0]][xyz[1]][xyz[2]]= idx
        global tries
        tries+= 1
        
        if tries % 30000 == 0:
            print tries, xyz, " ->" , idx, ": ", snake[idx]
    
        for _xyz in [addXyz(_add) for _add in ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1))]:
            solve(_xyz, idx + 1, currentState)
    
        currentState[xyz[0]][xyz[1]][xyz[2]]= 0
    
    def solved(result):
        print "SOLVED", tries
        print getCube(result)
        if exit_after_first_solution:
            sys.exit
    
    solve((1, 1, 1), 0, result)



for i in range(slen):
    print "Starting over", i

    solveSnake(snake[i:] + snake[:i])
