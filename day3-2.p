/*
--- Part Two ---

It turns out that this circuit is very timing-sensitive; you actually need to minimize the signal delay.

To do this, calculate the number of steps each wire takes to reach each intersection; choose the intersection where the sum of both wires' steps is lowest. If a wire visits a position on the grid multiple times, use the steps value from the first time it visits that position when calculating the total value of a specific intersection.

The number of steps a wire takes is the total number of grid squares the wire has entered to get to that location, including the intersection being considered. Again consider the example from above:

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

In the above example, the intersection closest to the central port is reached after 8+5+5+2 = 20 steps by the first wire and 7+6+4+3 = 20 steps by the second wire for a total of 20+20 = 40 steps.

However, the top-right intersection is better: the first wire takes only 8+5+2 = 15 and the second wire takes only 7+6+2 = 15, a total of 15+15 = 30 steps.

Here are the best steps for the extra examples from above:

    R75,D30,R83,U83,L12,D49,R71,U7,L72
    U62,R66,U55,R34,D71,R55,D58,R83 = 610 steps
    R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
    U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = 410 steps

What is the fewest combined steps the wires must take to reach an intersection?

*/

ETIME(YES).

DEFINE VARIABLE cWire2     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cWire1     AS CHARACTER   NO-UNDO.

DEFINE TEMP-TABLE ttGrid NO-UNDO
 FIELD X          AS INTEGER  
 FIELD Y          AS INTEGER  
 FIELD iDist      AS INTEGER  
 FIELD iWireSteps AS INTEGER  
 FIELD lWire1     AS LOGICAL  
 FIELD lWire2     AS LOGICAL  
 INDEX ixy IS PRIMARY UNIQUE X Y
 INDEX il lWire1 lWire2
 INDEX id iDist ASCENDING
 INDEX isteps iWireSteps ASCENDING
 .

INPUT FROM C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day3.txt.
IMPORT cWire1.
IMPORT cWire2.
INPUT CLOSE.

PROCEDURE markWire:    
    DEFINE INPUT  PARAMETER cWire AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER piWire AS INTEGER     NO-UNDO.

    DEFINE VARIABLE cDirection  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cPath       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i           AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iDeltaX     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iDeltaY     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iNbPaths    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iSteps      AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iTotalSteps AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iX          AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iY          AS INTEGER     NO-UNDO.
    DEFINE VARIABLE j           AS INTEGER     NO-UNDO.


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
        DO j = 1 TO iSteps:
            ASSIGN
                iX = iX + iDeltaX
                iY = iY + iDeltaY
                iTotalSteps = iTotalSteps + 1.
            FIND ttGrid WHERE ttGrid.X = iX AND ttGrid.Y = iY NO-ERROR.
            IF NOT AVAILABLE ttGrid THEN DO:
                CREATE ttGrid.
                ASSIGN ttGrid.X     = iX
                       ttGrid.Y     = iY
                       ttGrid.iDist = ABSOLUTE(iX) + ABSOLUTE(iY)
                       .
            END.
            ttGrid.iWireSteps = ttGrid.iWireSteps + iTotalSteps.
            IF piWire = 1 THEN
                ttGrid.lWire1 = YES.
            ELSE
                ttGrid.lWire2 = YES.
        END.
    END.
END PROCEDURE.

RUN markWire (cWire1, 1).
RUN markWire (cWire2, 2).

FOR EACH ttGrid WHERE ttGrid.lWire1 = YES AND ttGrid.lWire2 = YES BY ttGrid.iWireSteps:
    LEAVE.
END.

MESSAGE ETIME SKIP ttGrid.iWireSteps
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
8982 
164012
---------------------------
Aceptar   Ayuda   
---------------------------
*/
