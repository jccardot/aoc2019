/*
--- Part Two ---

All this drifting around in space makes you wonder about the nature of the universe. Does history really repeat itself? You're curious whether the moons will ever return to a previous state.

Determine the number of steps that must occur before all of the moons' positions and velocities exactly match a previous point in time.

For example, the first example above takes 2772 steps before they exactly match a previous point in time; it eventually returns to the initial state:

After 0 steps:
pos=<x= -1, y=  0, z=  2>, vel=<x=  0, y=  0, z=  0>
pos=<x=  2, y=-10, z= -7>, vel=<x=  0, y=  0, z=  0>
pos=<x=  4, y= -8, z=  8>, vel=<x=  0, y=  0, z=  0>
pos=<x=  3, y=  5, z= -1>, vel=<x=  0, y=  0, z=  0>

After 2770 steps:
pos=<x=  2, y= -1, z=  1>, vel=<x= -3, y=  2, z=  2>
pos=<x=  3, y= -7, z= -4>, vel=<x=  2, y= -5, z= -6>
pos=<x=  1, y= -7, z=  5>, vel=<x=  0, y= -3, z=  6>
pos=<x=  2, y=  2, z=  0>, vel=<x=  1, y=  6, z= -2>

After 2771 steps:
pos=<x= -1, y=  0, z=  2>, vel=<x= -3, y=  1, z=  1>
pos=<x=  2, y=-10, z= -7>, vel=<x= -1, y= -3, z= -3>
pos=<x=  4, y= -8, z=  8>, vel=<x=  3, y= -1, z=  3>
pos=<x=  3, y=  5, z= -1>, vel=<x=  1, y=  3, z= -1>

After 2772 steps:
pos=<x= -1, y=  0, z=  2>, vel=<x=  0, y=  0, z=  0>
pos=<x=  2, y=-10, z= -7>, vel=<x=  0, y=  0, z=  0>
pos=<x=  4, y= -8, z=  8>, vel=<x=  0, y=  0, z=  0>
pos=<x=  3, y=  5, z= -1>, vel=<x=  0, y=  0, z=  0>

Of course, the universe might last for a very long time before repeating. Here's a copy of the second example from above:

<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>

This set of initial positions takes 4686774924 steps before it repeats a previous state! Clearly, you might need to find a more efficient way to simulate the universe.

How many steps does it take to reach the first state that exactly matches a previous state?

*/

USING System.*. 

/* 
<x=-4,  y=-9,  z=-3>
<x=-13, y=-11, z=0 >
<x=-17, y=-7,  z=15>
<x=-16, y=4,   z=2 > 
*/

DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
DEFINE VARIABLE iStep  AS INTEGER   NO-UNDO.
DEFINE VARIABLE iVX    AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iVY    AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iVZ    AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iX     AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iXInit AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iY     AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iYInit AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iZ     AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE iZInit AS INTEGER   EXTENT 4 NO-UNDO.
DEFINE VARIABLE j      AS INTEGER   NO-UNDO.

ETIME(YES).

ASSIGN
    iX[1] = -4
    iY[1] = -9
    iZ[1] = -3
    iX[2] = -13
    iY[2] = -11
    iZ[2] = 0
    iX[3] = -17
    iY[3] = -7
    iZ[3] = 15
    iX[4] = -16
    iY[4] = 4
    iZ[4] = 2
    .

ASSIGN
    iXInit = iX
    iYInit = iY
    iZInit = iZ.


FUNCTION applyGravity RETURNS LOGICAL ( i AS INTEGER, j AS INTEGER ):
    IF iX[i] < iX[j] THEN ASSIGN
        iVX[i] = iVX[i] + 1
        iVX[j] = iVX[j] - 1.
    ELSE IF iX[i] > iX[j] THEN ASSIGN
        iVX[i] = iVX[i] - 1
        iVX[j] = iVX[j] + 1.
    IF iY[i] < iY[j] THEN ASSIGN
        iVY[i] = iVY[i] + 1
        iVY[j] = iVY[j] - 1.
    ELSE IF iY[i] > iY[j] THEN ASSIGN
        iVY[i] = iVY[i] - 1
        iVY[j] = iVY[j] + 1.
    IF iZ[i] < iZ[j] THEN ASSIGN
        iVZ[i] = iVZ[i] + 1
        iVZ[j] = iVZ[j] - 1.
    ELSE IF iZ[i] > iZ[j] THEN ASSIGN
        iVZ[i] = iVZ[i] - 1
        iVZ[j] = iVZ[j] + 1.
END FUNCTION.

DO WHILE TRUE:
    iStep = iStep + 1.
    DO i = 1 TO 3:
        DO j = i + 1 TO 4:
            applyGravity(i, j).
        END.
    END.
    DO i = 1 TO 4:
        ASSIGN
            iX[i] = iX[i] + iVX[i]
            iY[i] = iY[i] + iVY[i]
            iZ[i] = iZ[i] + iVZ[i].
    END.
    /* check each coordinate period (i.e. how many steps to get the same position and speed = 0) */
    DEFINE VARIABLE iPeriodX AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iPeriodY AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iPeriodZ AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lOKx     AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE lOKy     AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE lOKz     AS LOGICAL   NO-UNDO.
    lOKx = YES.
    lOKy = YES.
    lOKz = YES.
    DO i = 1 TO 4:
        IF iPeriodX = 0 THEN
            lOKx = lOKx AND iX[i] = iXInit[i] AND iVX[i] = 0.
        IF iPeriodY = 0 THEN
            lOKy = lOKy AND iY[i] = iYInit[i] AND iVY[i] = 0.
        IF iPeriodZ = 0 THEN
            lOKz = lOKz AND iZ[i] = iZInit[i] AND iVZ[i] = 0.
    END.
    IF iPeriodX = 0 AND lokx THEN iPeriodX = iStep.
    IF iPeriodY = 0 AND loky THEN iPeriodY = iStep. 
    IF iPeriodZ = 0 AND lokz THEN iPeriodZ = iStep.
    IF iPeriodX > 0 AND iPeriodY > 0 AND iPeriodZ > 0 THEN
        LEAVE.
END.

/* The result is the LCM of the 3 periods */

function gcd returns int64 (x as int64, y as int64):
    if y = 0 then return x.
    return gcd(y, x mod y).
end function.
function lcm returns int64 (x as int64, y as int64):
    return int64((x * y) / gcd(x, y)).
end function.

MESSAGE ETIME SKIP "LCM(" iPeriodX "," iPeriodY "," iPeriodZ ") =" lcm(iPeriodX, lcm(iPeriodY, iPeriodZ))
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
13084 
LCM( 113028 , 167624 , 231614 ) = 548525804273976
---------------------------
Aceptar   Ayuda   
---------------------------
*/
