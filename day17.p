/*
--- Day 17: Set and Forget ---

An early warning system detects an incoming solar flare and automatically activates the ship's electromagnetic shield. Unfortunately, this has cut off the Wi-Fi for many small robots that, unaware of the impending danger, are now trapped on exterior scaffolding on the unsafe side of the shield. To rescue them, you'll have to act quickly!

The only tools at your disposal are some wired cameras and a small vacuum robot currently asleep at its charging station. The video quality is poor, but the vacuum robot has a needlessly bright LED that makes it easy to spot no matter where it is.

An Intcode program, the Aft Scaffolding Control and Information Interface (ASCII, your puzzle input), provides access to the cameras and the vacuum robot. Currently, because the vacuum robot is asleep, you can only access the cameras.

Running the ASCII program on your Intcode computer will provide the current view of the scaffolds. This is output, purely coincidentally, as ASCII code: 35 means #, 46 means ., 10 starts a new line of output below the current one, and so on. (Within a line, characters are drawn left-to-right.)

In the camera output, # represents a scaffold and . represents open space. The vacuum robot is visible as ^, v, <, or > depending on whether it is facing up, down, left, or right respectively. When drawn like this, the vacuum robot is always on a scaffold; if the vacuum robot ever walks off of a scaffold and begins tumbling through space uncontrollably, it will instead be visible as X.

In general, the scaffold forms a path, but it sometimes loops back onto itself. For example, suppose you can see the following view from the cameras:

..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^..

Here, the vacuum robot, ^ is facing up and sitting at one end of the scaffold near the bottom-right of the image. The scaffold continues up, loops across itself several times, and ends at the top-left of the image.

The first step is to calibrate the cameras by getting the alignment parameters of some well-defined points. Locate all scaffold intersections; for each, its alignment parameter is the distance between its left edge and the left edge of the view multiplied by the distance between its top edge and the top edge of the view. Here, the intersections from the above image are marked O:

..#..........
..#..........
##O####...###
#.#...#...#.#
##O###O###O##
..#...#...#..
..#####...^..

For these intersections:

    The top-left intersection is 2 units from the left of the image and 2 units from the top of the image, so its alignment parameter is 2 * 2 = 4.
    The bottom-left intersection is 2 units from the left and 4 units from the top, so its alignment parameter is 2 * 4 = 8.
    The bottom-middle intersection is 6 from the left and 4 from the top, so its alignment parameter is 24.
    The bottom-right intersection's alignment parameter is 40.

To calibrate the cameras, you need the sum of the alignment parameters. In the above example, this is 76.

Run your ASCII program. What is the sum of the alignment parameters for the scaffold intersections?

*/

ETIME(YES).

DEFINE VARIABLE iRam AS INT64 EXTENT 6000 NO-UNDO.
DEFINE VARIABLE lcRam AS LONGCHAR  INIT "{C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day17.txt}"   NO-UNDO.

DEFINE VARIABLE iii AS INTEGER     NO-UNDO.
DO iii = 1 TO NUM-ENTRIES(lcRam):
    iRam[iii] = INTEGER(ENTRY(iii, lcRam)).
END.

DEFINE VARIABLE iRamInit AS INT64 EXTENT NO-UNDO.

iRamInit = iRam.

FUNCTION ramValue RETURNS INT64 ( iRam AS INT64 EXTENT, iPC AS INTEGER, cMode AS CHARACTER, iRelBase AS INTEGER ):
    RETURN iRam[IF cMode = "1" THEN iPC ELSE IF cMode = "2" THEN iRam[iPC] + iRelBase + 1 ELSE iRam[iPC] + 1].
END FUNCTION.

FUNCTION runProgram RETURNS LOGICAL (
    INPUT-OUTPUT iRam AS INT64 EXTENT,
    INPUT-OUTPUT iPc AS INTEGER,
    INPUT-OUTPUT iRelBase AS INTEGER,
    pcInput AS CHARACTER,
    OUTPUT pcOutput AS LONGCHAR):

    DEFINE VARIABLE cMode1      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMode2      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMode3      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cOpcode     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE iInputIndex AS INTEGER     INITIAL 1 NO-UNDO.
    DEFINE VARIABLE iNbInput    AS INTEGER     NO-UNDO.

    iNbInput = NUM-ENTRIES(pcInput).

    blkProgram:
    DO WHILE TRUE:
        cOpcode = STRING(iRam[iPC], "99999").
        ASSIGN
            cMode3  = SUBSTRING(cOpcode,1,1)
            cMode2  = SUBSTRING(cOpcode,2,1)
            cMode1  = SUBSTRING(cOpcode,3,1)
            cOpcode = SUBSTRING(cOpcode,4,2)
            .
        CASE cOpcode:
            WHEN "01" THEN DO:
                iRam[iRam[iPC + 3] + (IF cMode3 = "2" THEN iRelBase ELSE 0) + 1] = ramValue(iRam, iPC + 1, cMode1, iRelBase) + ramValue(iRam, iPC + 2, cMode2, iRelBase).
                iPC = iPC + 4.
            END.
            WHEN "02" THEN DO:
                iRam[iRam[iPC + 3] + (IF cMode3 = "2" THEN iRelBase ELSE 0) + 1] = ramValue(iRam, iPC + 1, cMode1, iRelBase) * ramValue(iRam, iPC + 2, cMode2, iRelBase).
                iPC = iPC + 4.
            END.
            WHEN "03" THEN DO: /* input */
                IF iInputIndex > iNbInput THEN RETURN TRUE. /* stop to wait for more input */
                iRam[iRam[iPC + 1] + (IF cMode1 = "2" THEN iRelBase ELSE 0) + 1] = INT64(ENTRY(iInputIndex, pcInput)).
                iInputIndex = iInputIndex + 1.
                iPC = iPC + 2.
            END.
            WHEN "04" THEN DO: /* output */
                pcOutput = pcOutput + "," + STRING(ramValue(iRam, iPC + 1, cMode1, iRelBase)).
                iPC = iPC + 2.
            END.
            WHEN "05" THEN DO: /* jump-if-true */
                IF ramValue(iRam, iPC + 1, cMode1, iRelBase) <> 0 THEN
                    iPC = ramValue(iRam, iPC + 2, cMode2, iRelBase) + 1.
                ELSE
                    iPC = iPC + 3.
            END.
            WHEN "06" THEN DO: /* jump-if-false */
                IF ramValue(iRam, iPC + 1, cMode1, iRelBase) = 0 THEN
                    iPC = ramValue(iRam, iPC + 2, cMode2, iRelBase) + 1.
                ELSE
                    iPC = iPC + 3.
            END.
            WHEN "07" THEN DO: /* less than */
                iRam[iRam[iPC + 3] + (IF cMode3 = "2" THEN iRelBase ELSE 0) + 1] = IF ramValue(iRam, iPC + 1, cMode1, iRelBase) < ramValue(iRam, iPC + 2, cMode2, iRelBase) THEN 1 ELSE 0.
                iPC = iPC + 4.
            END.
            WHEN "08" THEN DO: /* equals */
                iRam[iRam[iPC + 3] + (IF cMode3 = "2" THEN iRelBase ELSE 0) + 1] = IF ramValue(iRam, iPC + 1, cMode1, iRelBase) = ramValue(iRam, iPC + 2, cMode2, iRelBase) THEN 1 ELSE 0.
                iPC = iPC + 4.
            END.
            WHEN "09" THEN DO: /* update relative base */
                iRelBase = iRelBase + ramValue(iRam, iPC + 1, cMode1, iRelBase).
                iPC = iPC + 2.
            END.
            WHEN "99" THEN
                LEAVE blkProgram.
            OTHERWISE DO:
                MESSAGE SUBSTITUTE("Invalid opcode &2 at address &1", iPC, cOpcode)
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
                QUIT.
            END.
        END CASE.
    END.

    RETURN FALSE.

END FUNCTION.

DEFINE VARIABLE cOutput AS LONGCHAR   NO-UNDO.
DEFINE VARIABLE i       AS INTEGER     NO-UNDO.

DEFINE VARIABLE cParam1   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE iPC1      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iRam1     AS INT64       EXTENT 6000 NO-UNDO.
DEFINE VARIABLE iRelBase1 AS INTEGER     NO-UNDO.
DEFINE VARIABLE lAmp1     AS LOGICAL     NO-UNDO.

ASSIGN
    iRam1     = 0
    iPC1      = 1
    iRelBase1 = 0
    lAmp1     = YES
    cParam1   = ""
    .

DO i = EXTENT(iRamInit) TO 1 BY -1:
    iRam1[i] = iRamInit[i].
END.

FUNCTION paintMap RETURNS CHARACTER ( cOutput AS LONGCHAR ):    
    DEFINE VARIABLE cMap AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i    AS INTEGER     NO-UNDO.
    DO i = 1 TO NUM-ENTRIES(cOutput):
        cMap = cMap + CHR(INTEGER(ENTRY(i, cOutput))).
    END.
    RETURN cMap.
END FUNCTION.

/* initial run - cache the initial state */
&GLOBAL-DEFINE xcCacheRam C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day17.ram
&GLOBAL-DEFINE xcCacheOutput C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day17.output

IF SEARCH("{&xcCacheRam}") = ? THEN DO:
    lAmp1 = runProgram(iRam1, iPC1, iRelBase1, cParam1, OUTPUT cOutput).
    cOutput = SUBSTRING(cOutput, 2).
    OUTPUT TO {&xcCacheRam}.
    EXPORT iPC1 iRelBase1 SKIP.
    DO iii = 1 TO 6000:
        EXPORT iRam1[iii] SKIP.
    END.
    OUTPUT CLOSE.
    COPY-LOB cOutput TO FILE "{&xcCacheOutput}".
END.
ELSE DO:
    INPUT FROM {&xcCacheRam}.
    IMPORT iPC1 iRelBase1.
    DO iii = 1 TO 6000:
        IMPORT iRam1[iii]   .
    END.
    INPUT CLOSE.
    lAmp1 = YES.
    COPY-LOB FILE "{&xcCacheOutput}" TO cOutput.
END.

/* now detect intersections */
DEFINE VARIABLE cLine   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cMap    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE iHeight AS INTEGER     NO-UNDO.
DEFINE VARIABLE iPos    AS INTEGER     NO-UNDO.
DEFINE VARIABLE iTotal  AS INTEGER     NO-UNDO.
DEFINE VARIABLE iWidth  AS INTEGER     NO-UNDO.
DEFINE VARIABLE j       AS INTEGER     NO-UNDO.

FUNCTION getPointAt RETURNS CHARACTER ( cMap AS CHARACTER, iX AS INTEGER, iY AS INTEGER ):    
    RETURN SUBSTRING(ENTRY(iY + 1, cMap, CHR(10)), iX + 1, 1).
END FUNCTION.
FUNCTION setPointAt RETURNS CHARACTER ( INPUT-OUTPUT cMap AS CHARACTER, iX AS INTEGER, iY AS INTEGER, cValue AS CHARACTER ):
    DEFINE VARIABLE cLine AS CHARACTER   NO-UNDO.
    cLine = ENTRY(iY + 1, cMap, CHR(10)).
    SUBSTRING(cLine, iX + 1, 1) = cValue.
    ENTRY(iY + 1, cMap, CHR(10)) = cLine.
END FUNCTION.

cMap = paintMap(cOutput).

iHeight = NUM-ENTRIES(cMap, CHR(10)).
iWidth = LENGTH(ENTRY(1, cMap, CHR(10))).
DO j = 2 TO iHeight - 1:
    cLine = ENTRY(j, cMap, CHR(10)).
    iPos = INDEX(cLine, "###").
    DO WHILE iPos > 0:
        IF getPointAt(cMap, iPos, j - 2) = "#" AND getPointAt(cMap, iPos, j) = "#" THEN DO:
            setPointAt(cMap, iPos, j - 1, "O").
            iTotal = iTotal + iPos * (j - 1).
        END.
        iPos = INDEX(cLine, "###", iPos + 1).
    END.
END.

OUTPUT TO C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day17.map.
EXPORT cMap.
OUTPUT CLOSE.

MESSAGE ETIME SKIP lAmp1 iPC1 iRelBase1 SKIP iTotal SKIP cMap
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
513 
yes 62 4632 
8408 
........................................#########...........#########........
........................................#.......#...........#.......#........
........................................#.......#...........#.......#........
........................................#.......#...........#.......#........
........................................#.......#...........#.......#........
........................................#.......#...........#.......#........
........................................#.......#...........#.......#........
........................................#.......#...........#.......#........
........................................#.......#.......####O########........
........................................#.......#.......#...#................
#########...................#############.......#.....^#O####................
#.......#...................#...................#.......#....................
#.......#...................#...................########O##..................
#.......#...................#...........................#.#..................
#.......#...................#...........................#.#..................
#.......#...................#...........................#.#..................
#.......#...................#...........................##O########..........
#.......#...................#.............................#.......#..........
########O##.................#.............................########O##........
........#.#.................#.....................................#.#........
........#.#...........#######.....................................#.#........
........#.#...........#...........................................#.#........
........##O########...#...........................................##O########
..........#.......#...#.............................................#.......#
..........########O##.#.............................................#.......#
..................#.#.#.............................................#.......#
..................#.#.#.............................................#.......#
..................#.#.#.............................................#.......#
..................##O#O######.......................................#.......#
....................#.#.............................................#.......#
................####O##.............................................#########
................#...#........................................................
........########O####........................................................
........#.......#............................................................
........#.......#............................................................
........#.......#............................................................
........#.......#............................................................
........#.......#............................................................
........#.......#............................................................
........#.......#............................................................
........#########............................................................
---------------------------
Aceptar   Ayuda   
---------------------------
*/
    
