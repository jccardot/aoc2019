/*
--- Part Two ---

Once you give them the coordinates, the Elves quickly deploy an Instant Monitoring Station to the location and discover the worst: there are simply too many asteroids.

The only solution is complete vaporization by giant laser.

Fortunately, in addition to an asteroid scanner, the new monitoring station also comes equipped with a giant rotating laser perfect for vaporizing asteroids. The laser starts by pointing up and always rotates clockwise, vaporizing any asteroid it hits.

If multiple asteroids are exactly in line with the station, the laser only has enough power to vaporize one of them before continuing its rotation. In other words, the same asteroids that can be detected can be vaporized, but if vaporizing one asteroid makes another one detectable, the newly-detected asteroid won't be vaporized until the laser has returned to the same position by rotating a full 360 degrees.

For example, consider the following map, where the asteroid with the new monitoring station (and laser) is marked X:

.#....#####...#..
##...##.#####..##
##...#...#.#####.
..#.....X...###..
..#.#.....#....##

The first nine asteroids to get vaporized, in order, would be:

.#....###24...#..
##...##.13#67..9#
##...#...5.8####.
..#.....X...###..
..#.#.....#....##

Note that some asteroids (the ones behind the asteroids marked 1, 5, and 7) won't have a chance to be vaporized until the next full rotation. The laser continues rotating; the next nine to be vaporized are:

.#....###.....#..
##...##...#.....#
##...#......1234.
..#.....X...5##..
..#.9.....8....76

The next nine to be vaporized are then:

.8....###.....#..
56...9#...#.....#
34...7...........
..2.....X....##..
..1..............

Finally, the laser completes its first full rotation (1 through 3), a second rotation (4 through 8), and vaporizes the last asteroid (9) partway through its third rotation:

......234.....6..
......1...5.....7
.................
........X....89..
.................

In the large example above (the one with the best monitoring station location at 11,13):

    The 1st asteroid to be vaporized is at 11,12.
    The 2nd asteroid to be vaporized is at 12,1.
    The 3rd asteroid to be vaporized is at 12,2.
    The 10th asteroid to be vaporized is at 12,8.
    The 20th asteroid to be vaporized is at 16,0.
    The 50th asteroid to be vaporized is at 16,9.
    The 100th asteroid to be vaporized is at 10,16.
    The 199th asteroid to be vaporized is at 9,6.
    The 200th asteroid to be vaporized is at 8,2.
    The 201st asteroid to be vaporized is at 10,9.
    The 299th and final asteroid to be vaporized is at 11,1.

The Elves are placing bets on which will be the 200th asteroid to be vaporized. Win the bet by determining which asteroid that will be; what do you get if you multiply its X coordinate by 100 and then add its Y coordinate? (For example, 8,2 becomes 802.)

*/

USING System.Math.

ETIME(YES).

DEFINE VARIABLE cMap AS CHARACTER  INITIAL "{C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day10.txt}" NO-UNDO.
&GLOBAL-DEFINE xiColumns 24
&GLOBAL-DEFINE xiLines 24
&GLOBAL-DEFINE xiCenterX 20
&GLOBAL-DEFINE xiCenterY 18

FUNCTION getPointAt RETURNS CHARACTER ( X AS INTEGER, Y AS INTEGER ):    
    RETURN SUBSTRING( cMap, 1 + {&xiColumns} * Y + X, 1).
END FUNCTION.

/* For day2 use a different approach: for each asteroid, compute the angle from the center point - the center point being the point found in part 1 */

FUNCTION getAngle RETURNS DECIMAL (iX AS INTEGER, iY AS INTEGER):  
    DEFINE VARIABLE deAngle AS DECIMAL     NO-UNDO.
    deAngle = - Math:PI - Math:Atan2(iX - {&xiCenterX}, iY - {&xiCenterY}).
    DO WHILE deAngle < 0:
        deAngle = deAngle + 2 * Math:PI.
    END.
    RETURN deAngle / Math:PI * 180.
END FUNCTION.

FUNCTION getDistance RETURNS DECIMAL (iX AS INTEGER, iY AS INTEGER):
    RETURN SQRT(EXP(iY - {&xiCenterY}, 2) + EXP(iX - {&xiCenterX}, 2)).
END FUNCTION.

DEFINE TEMP-TABLE ttAsteroid NO-UNDO 
 FIELD iX      AS INTEGER  
 FIELD iY      AS INTEGER  
 FIELD deDist  AS DECIMAL
 FIELD deAngle AS DECIMAL  
 INDEX iad deAngle deDist.

DEFINE VARIABLE iX AS INTEGER     NO-UNDO.
DEFINE VARIABLE iY AS INTEGER     NO-UNDO.
DEFINE VARIABLE iChar AS INTEGER     NO-UNDO.

DO iChar = 1 TO LENGTH(cMap):
    IF NOT (iX = {&xiCenterX} AND iY = {&xiCenterY}) AND SUBSTRING(cMap, iChar, 1) = "#" THEN DO:
        CREATE ttAsteroid.
        ASSIGN
            ttAsteroid.iX      = iX
            ttAsteroid.iY      = iY
            ttAsteroid.deDist  = getDistance(iX, iY)
            ttAsteroid.deAngle = getAngle(iX, iY).

    END.
    iX = iX + 1.
    IF iX > {&xiColumns} - 1 THEN ASSIGN
        iY = iY + 1
        iX = 0.
END.

/* Now vaporize'em! */
DEFINE VARIABLE deLastAngle AS DECIMAL   INITIAL ? NO-UNDO.
DEFINE VARIABLE iCount      AS INTEGER   NO-UNDO.
DEFINE VARIABLE iRound      AS INTEGER   NO-UNDO.

DO WHILE CAN-FIND(FIRST ttAsteroid):
    ASSIGN
        iRound      = iRound + 1
        deLastAngle = ?.
    blkAsteroid:
    FOR EACH ttAsteroid:
        IF ttAsteroid.deAngle = deLastAngle THEN NEXT blkAsteroid.
        iCount = iCount + 1.
        IF iCount = 200 THEN DO:
            MESSAGE ETIME SKIP iRound "round(s)" SKIP ttAsteroid.iX * 100 + ttAsteroid.iY
                VIEW-AS ALERT-BOX INFO BUTTONS OK.            
            STOP.
        END.
        deLastAngle = ttAsteroid.deAngle.
        DELETE ttAsteroid.
    END.
END.

/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
62 
1 round(s) 
706
---------------------------
Aceptar   Ayuda   
---------------------------
*/

