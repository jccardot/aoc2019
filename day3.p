/*
--- Day 3: Crossed Wires ---

The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

...........
...........
...........
....+----+.
....|....|.
....|....|.
....|....|.
.........|.
.o-------+.
...........

Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........

These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

Here are a few more examples:

    R75,D30,R83,U83,L12,D49,R71,U7,L72
    U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
    R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
    U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135

What is the Manhattan distance from the central port to the closest intersection?

*/

ETIME(YES).

DEFINE VARIABLE cWire2     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cWire1     AS CHARACTER   NO-UNDO.

DEFINE TEMP-TABLE ttGrid NO-UNDO
 FIELD X      AS INTEGER  
 FIELD Y      AS INTEGER  
 FIELD iDist  AS INTEGER  
 FIELD lWire1 AS LOGICAL  
 FIELD lWire2 AS LOGICAL  
 INDEX ixy IS PRIMARY UNIQUE X Y
 INDEX il lWire1 lWire2
 INDEX id iDist ASCENDING
 .

INPUT FROM C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day3.txt.
IMPORT cWire1.
IMPORT cWire2.
INPUT CLOSE.

PROCEDURE markWire:    
    DEFINE INPUT  PARAMETER cWire AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER piWire AS INTEGER     NO-UNDO.

    DEFINE VARIABLE cDirection AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i          AS INTEGER     NO-UNDO.
    DEFINE VARIABLE cPath      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE iDeltaX    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iDeltaY    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iNbPaths   AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iSteps     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iX         AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iY         AS INTEGER     NO-UNDO.
    DEFINE VARIABLE j          AS INTEGER     NO-UNDO.


    ASSIGN
        iX       = 0
        iY       = 0
        iNbPaths = NUM-ENTRIES(cWire).
    DO i = 1 TO iNbPaths:
        cPath = ENTRY(i, cWire).
        cDirection = SUBSTRING(cPath,1,1).
        iSteps = INTEGER(SUBSTRING(cPath,2)).
        CASE cDirection:
            WHEN "U" THEN ASSIGN
                iDeltaX = 0
                iDeltaY = 1.
            WHEN "D" THEN ASSIGN
                iDeltaX = 0
                iDeltaY = -1.
            WHEN "R" THEN ASSIGN
                iDeltaX = 1
                iDeltaY = 0.
            WHEN "L" THEN ASSIGN
                iDeltaX = -1
                iDeltaY = 0.
        END CASE.
        DO j = iSteps TO 1 BY -1:
            ASSIGN
                iX = iX + iDeltaX
                iY = iY + iDeltaY.
            FIND ttGrid WHERE ttGrid.X = iX AND ttGrid.Y = iY NO-ERROR.
            IF NOT AVAILABLE ttGrid THEN DO:
                CREATE ttGrid.
                ASSIGN ttGrid.X     = iX
                       ttGrid.Y     = iY
                       ttGrid.iDist = ABSOLUTE(iX) + ABSOLUTE(iY).
            END.
            IF piWire = 1 THEN
                ttGrid.lWire1 = YES.
            ELSE
                ttGrid.lWire2 = YES.
        END.
    END.
END PROCEDURE.

RUN markWire (cWire1, 1).
RUN markWire (cWire2, 2).

FOR EACH ttGrid WHERE ttGrid.lWire1 = YES AND ttGrid.lWire2 = YES BY ttGrid.iDist:
    LEAVE.
END.

MESSAGE ETIME SKIP ttGrid.iDist
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
6971 
4981
---------------------------
Aceptar   Ayuda   
---------------------------
*/
