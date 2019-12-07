/*
--- Part Two ---

Now, you just need to figure out how many orbital transfers you (YOU) need to take to get to Santa (SAN).

You start at the object YOU are orbiting; your destination is the object SAN is orbiting. An orbital transfer lets you move from any object to an object orbiting or orbited by that object.

For example, suppose you have the following map:

COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN

Visually, the above map of orbits looks like this:

                          YOU
                         /
        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I - SAN

In this example, YOU are in orbit around K, and SAN is in orbit around I. To move from K to I, a minimum of 4 orbital transfers are required:

    K to J
    J to E
    E to D
    D to I

Afterward, the map of orbits looks like this:

        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I - SAN
                 \
                  YOU

What is the minimum number of orbital transfers required to move from the object YOU are orbiting to the object SAN is orbiting? (Between the objects they are orbiting - not between YOU and SAN.)

*/

ETIME(YES).

DEFINE TEMP-TABLE ttOrbit NO-UNDO 
    FIELD cCenter  AS CHARACTER
    FIELD cOrbiter AS CHARACTER
    FIELD cPath    AS CHARACTER
    INDEX io IS UNIQUE cOrbiter
    .

DEFINE BUFFER bttOrbit FOR ttOrbit.

DEFINE VARIABLE cCenter    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cPathSanta AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cPathYou   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i          AS INTEGER     NO-UNDO.
DEFINE VARIABLE iPathSanta AS INTEGER     NO-UNDO.
DEFINE VARIABLE iPathYou   AS INTEGER     NO-UNDO.
DEFINE VARIABLE j          AS INTEGER     NO-UNDO.

INPUT FROM C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day6.txt.
REPEAT:
    CREATE ttOrbit.
    IMPORT DELIMITER ")" ttOrbit.cCenter ttOrbit.cOrbiter.
END.
DELETE ttOrbit.
INPUT CLOSE.

FOR EACH ttOrbit WHERE ttOrbit.cOrbiter = "YOU" OR ttOrbit.cOrbiter = "SAN":
    cCenter = ttOrbit.cCenter.
    ttOrbit.cPath = cCenter.
    DO WHILE TRUE:
        FIND bttOrbit WHERE bttOrbit.cOrbiter = cCenter.
        IF bttOrbit.cCenter = "COM" THEN LEAVE.
        cCenter = bttOrbit.cCenter.
        ttOrbit.cPath = cCenter + "," + ttOrbit.cPath.
    END.
END.

FIND ttOrbit WHERE ttOrbit.cOrbiter = "YOU".
cPathYou = ttOrbit.cPath.
iPathYou = NUM-ENTRIES(cPathYou).
FIND ttOrbit WHERE ttOrbit.cOrbiter = "SAN".
cPathSanta = ttOrbit.cPath.
iPathSanta = NUM-ENTRIES(cPathSanta).

/* find first common center */
blkSearch:
DO i = iPathYou TO 1 BY -1:
    cCenter = ENTRY(i, cPathYou).
    DO j = iPathSanta TO 1 BY -1:
        IF ENTRY(j, cPathSanta) = cCenter THEN
            LEAVE blkSearch.
    END.
END.

MESSAGE ETIME SKIP iPathYou - i + iPathSanta - j
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
124 
397
---------------------------
Aceptar   Ayuda   
---------------------------
*/
