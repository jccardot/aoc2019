/*
--- Day 10: Monitoring Station ---

You fly into the asteroid belt and reach the Ceres monitoring station. The Elves here have an emergency: they're having trouble tracking all of the asteroids and can't be sure they're safe.

The Elves would like to build a new monitoring station in a nearby area of space; they hand you a map of all of the asteroids in that region (your puzzle input).

The map indicates whether each position is empty (.) or contains an asteroid (#). The asteroids are much smaller than they appear on the map, and every asteroid is exactly in the center of its marked position. The asteroids can be described with X,Y coordinates where X is the distance from the left edge and Y is the distance from the top edge (so the top-left corner is 0,0 and the position immediately to its right is 1,0).

Your job is to figure out which asteroid would be the best place to build a new monitoring station. A monitoring station can detect any asteroid to which it has direct line of sight - that is, there cannot be another asteroid exactly between them. This line of sight can be at any angle, not just lines aligned to the grid or diagonally. The best location is the asteroid that can detect the largest number of other asteroids.

For example, consider the following map:

.#..#
.....
#####
....#
...##

The best location for a new monitoring station on this map is the highlighted asteroid at 3,4 because it can detect 8 asteroids, more than any other location. (The only asteroid it cannot detect is the one at 1,0; its view of this asteroid is blocked by the asteroid at 2,2.) All other asteroids are worse locations; they can detect 7 or fewer other asteroids. Here is the number of other asteroids a monitoring station on each asteroid could detect:

.7..7
.....
67775
....7
...87

Here is an asteroid (#) and some examples of the ways its line of sight might be blocked. If there were another asteroid at the location of a capital letter, the locations marked with the corresponding lowercase letter would be blocked and could not be detected:

#.........
...A......
...B..a...
.EDCG....a
..F.c.b...
.....c....
..efd.c.gb
.......c..
....f...c.
...e..d..c

Here are some larger examples:

    Best is 5,8 with 33 other asteroids detected:

    ......#.#.
    #..#.#....
    ..#######.
    .#.#.###..
    .#..#.....
    ..#....#.#
    #..#....#.
    .##.#..###
    ##...#..#.
    .#....####

    Best is 1,2 with 35 other asteroids detected:

    #.#...#.#.
    .###....#.
    .#....#...
    ##.#.#.#.#
    ....#.#.#.
    .##..###.#
    ..#...##..
    ..##....##
    ......#...
    .####.###.

    Best is 6,3 with 41 other asteroids detected:

    .#..#..###
    ####.###.#
    ....###.#.
    ..###.##.#
    ##.##.#.#.
    ....###..#
    ..#.#..#.#
    #..#.#.###
    .##...##.#
    .....#.#..

    Best is 11,13 with 210 other asteroids detected:

    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##

Find the best location for a new monitoring station. How many other asteroids can be detected from that location?

*/

ETIME(YES).

DEFINE VARIABLE cMapInit AS CHARACTER  INITIAL "{C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day10.txt}" NO-UNDO.
&GLOBAL-DEFINE xiColumns 24
&GLOBAL-DEFINE xiLines 24

DEFINE VARIABLE cMap AS CHARACTER   NO-UNDO.

FUNCTION getPointAt RETURNS CHARACTER ( X AS INTEGER, Y AS INTEGER ):    
    RETURN SUBSTRING( cMap, 1 + {&xiColumns} * Y + X, 1).
END FUNCTION.
FUNCTION setPointAt RETURNS LOGICAL ( X AS INTEGER, Y AS INTEGER, c AS CHARACTER ):    
    SUBSTRING( cMap, 1 + {&xiColumns} * Y + X, 1) = c.
    RETURN TRUE.
END FUNCTION.

FUNCTION debugMap RETURNS CHARACTER ( ):
    DEFINE VARIABLE cDebugMap AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE iLine     AS INTEGER     NO-UNDO.
    DO iLine = 0 TO {&xiLines} - 1:
        cDebugMap = cDebugMap + "~n" + SUBSTRING(cMap, iLine * {&xiColumns} + 1, {&xiColumns}).
    END.
    RETURN cDebugMap.
END FUNCTION.

DEFINE VARIABLE iAsteroids    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAsteroidsMax AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAsteroidX    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iAsteroidY    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iMaxX         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iMaxY         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iSightX       AS INTEGER   NO-UNDO.
DEFINE VARIABLE iSightY       AS INTEGER   NO-UNDO.
DEFINE VARIABLE iStationX     AS INTEGER   NO-UNDO.
DEFINE VARIABLE iStationY     AS INTEGER   NO-UNDO.
DEFINE VARIABLE lAsteroid     AS LOGICAL   NO-UNDO.

PROCEDURE sight:
    ASSIGN
        iAsteroidX = iStationX + iSightX
        iAsteroidY = iStationY + iSightY
        lAsteroid  = NO.
    DO WHILE iAsteroidX >= 0 AND iAsteroidX < {&xiColumns}
         AND iAsteroidY >= 0 AND iAsteroidY < {&xiLines}:
        IF lAsteroid THEN
            setPointAt(iAsteroidX, iAsteroidY, "o").
        ELSE
        IF getPointAt(iAsteroidX, iAsteroidY) = "#" THEN DO:
            ASSIGN
                iAsteroids = iAsteroids + 1
                lAsteroid  = YES.
            setPointAt(iAsteroidX, iAsteroidY, "X").
        END.
        ASSIGN
            iAsteroidX = iAsteroidX + iSightX
            iAsteroidY = iAsteroidY + iSightY.
    END.
END PROCEDURE.

DO iStationX = 0 TO {&xiColumns} - 1:
    DO iStationY = 0 TO {&xiLines} - 1:

        cMap = REPLACE(cMapInit, ".", "_").

        IF getPointAt(iStationX, iStationY) = "#" THEN
            iAsteroids = 0.
        ELSE
            NEXT.

        /* right */
        iSightY = 0.
        DO iSightX = 1 TO {&xiColumns} - 1 - iStationX:
            RUN sight.
        END.

        /* left */
        iSightY = 0.
        DO iSightX = -1 TO - iStationX BY -1:
            RUN sight.
        END.

        /* down */
        iSightX = 0.
        DO iSightY = 1 TO {&xiLines} - 1 - iStationY:
            RUN sight.
        END.

        /* up */
        iSightX = 0.
        DO iSightY = -1 TO - iStationY BY -1:
            RUN sight.
        END.

        /* right-bottom quadrant */
        DO iSightY = 1 TO {&xiLines} - 1 - iStationY:
            DO iSightX = 1 TO {&xiColumns} - 1 - iStationX:
                RUN sight.
            END.
        END.

        /* left-bottom quadrant */
        DO iSightY = -1 TO - iStationY BY -1:
            DO iSightX = 1 TO {&xiColumns} - 1 - iStationX:
                RUN sight.
            END.
        END.

        /* left-up quadrant */
        DO iSightY = -1 TO - iStationY BY -1:
            DO iSightX = -1 TO - iStationX BY -1:
                RUN sight.
            END.
        END.

        /* right-up quadrant */
        DO iSightY = 1 TO {&xiLines} - 1 - iStationY:
            DO iSightX = -1 TO - iStationX BY -1:
                RUN sight.
            END.
        END.

        IF iAsteroids > iAsteroidsMax THEN ASSIGN
            iAsteroidsMax = iAsteroids
            iMaxX         = iStationX
            iMaxY         = iStationY.

    END.
END.

MESSAGE ETIME SKIP iAsteroidsMax "@" iMaxX "," iMaxY
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
4381 
280 @ 20 , 18
---------------------------
Aceptar   Ayuda   
---------------------------
*/
