/*
--- Part Two ---

The game didn't run because you didn't put in any quarters. Unfortunately, you did not bring any quarters. Memory address 0 represents the number of quarters that have been inserted; set it to 2 to play for free.

The arcade cabinet has a joystick that can move left and right. The software reads the position of the joystick with input instructions:

    If the joystick is in the neutral position, provide 0.
    If the joystick is tilted to the left, provide -1.
    If the joystick is tilted to the right, provide 1.

The arcade cabinet also has a segment display capable of showing a single number that represents the player's current score. When three output instructions specify X=-1, Y=0, the third output instruction is not a tile; the value instead specifies the new score to show in the segment display. For example, a sequence of output values like -1,0,12345 would show 12345 as the player's current score.

Beat the game by breaking all the blocks. What is your score after the last block is broken?

*/

ETIME(YES).

DEFINE VARIABLE iRam AS INT64 EXTENT 4096    NO-UNDO.
DEFINE VARIABLE lcRam AS LONGCHAR  INIT "{C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day13.txt}"   NO-UNDO.

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
    OUTPUT pcOutput AS CHARACTER):

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

DEFINE VARIABLE cOutput AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i       AS INTEGER     NO-UNDO.

DEFINE VARIABLE cParam1   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE iPC1      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iRam1     AS INT64       EXTENT 4096 NO-UNDO.
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

&GLOBAL-DEFINE xiEmpty   0
&GLOBAL-DEFINE xiWall    1
&GLOBAL-DEFINE xiBlock   2
&GLOBAL-DEFINE xiPaddle  3
&GLOBAL-DEFINE xiBall    4

DEFINE VARIABLE cScore  AS CHARACTER   INITIAL ? NO-UNDO.
DEFINE VARIABLE cScreen AS CHARACTER   EXTENT 25 NO-UNDO.

FUNCTION paintScreen RETURNS CHARACTER ( lPaint AS LOGICAL ):    
    DEFINE VARIABLE cRet   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cTile  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iX     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iY     AS INTEGER     NO-UNDO.

    DO iii = 1 TO NUM-ENTRIES(cOutput) BY 3:
        ASSIGN
            iX = INTEGER(ENTRY(iii, cOutput))
            iY = INTEGER(ENTRY(iii + 1, cOutput)).
        IF iX = -1 THEN DO:
            cScore = ENTRY(iii + 2, cOutput).
            IF NOT lPaint THEN RETURN cScore.
        END.
        ELSE IF lPaint THEN CASE ENTRY(iii + 2, cOutput):
            WHEN "{&xiEmpty}" THEN
                SUBSTRING(cScreen[iY + 1], iX + 1, 1) = " ".
            WHEN "{&xiWall}" THEN
                SUBSTRING(cScreen[iY + 1], iX + 1, 1) = "#".
            WHEN "{&xiBlock}" THEN
                SUBSTRING(cScreen[iY + 1], iX + 1, 1) = "@".
            WHEN "{&xiPaddle}" THEN
                SUBSTRING(cScreen[iY + 1], iX + 1, 1) = "-".
            WHEN "{&xiBall}" THEN
                SUBSTRING(cScreen[iY + 1], iX + 1, 1) = "O".
        END CASE.
    END.
    IF lPaint THEN DO:
        cRet = SUBSTITUTE("Score: &1~n", cScore).
        DO i = 1 TO 25:
            cRet = cRet + cScreen[i] + "~n".
        END.
        RETURN cRet.
    END.
    ELSE
        RETURN cScore.
END FUNCTION.

iRam1[1] = 2.

DEFINE VARIABLE iX      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iY      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iXBall      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iYBall      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iXPaddle      AS INTEGER     NO-UNDO.

/* initial run - cache the initial state */
IF SEARCH("C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day13.ram") = ? THEN DO:
    lAmp1 = runProgram(iRam1, iPC1, iRelBase1, cParam1, OUTPUT cOutput).
    cOutput = SUBSTRING(cOutput, 2).
    OUTPUT TO C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day13.ram.
    EXPORT iPC1 iRelBase1 SKIP.
    EXPORT cOutput SKIP.
    DO iii = 1 TO NUM-ENTRIES(lcRam):
        EXPORT iRam1[iii] SKIP.
    END.
    OUTPUT CLOSE.
END.
ELSE DO:
    INPUT FROM C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day13.ram.
    IMPORT iPC1 iRelBase1.
    IMPORT cOutput.
    DO iii = 1 TO NUM-ENTRIES(lcRam):
        IMPORT iRam1[iii]   .
    END.
    INPUT CLOSE.
    lAmp1 = YES.
END.

DEFINE VARIABLE iStep AS INTEGER     NO-UNDO.

DEFINE STREAM sLog.
OUTPUT STREAM sLog TO C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day13.log.
PUT STREAM sLog UNFORMATTED "START" SKIP(1).
PUT STREAM sLog UNFORMATTED iStep SKIP ETIME SKIP paintScreen(YES) SKIP(1).
DO WHILE TRUE:
    iStep = iStep + 1.
    DO iii = 1 TO NUM-ENTRIES(cOutput) BY 3:
        ASSIGN
            iX = INTEGER(ENTRY(iii, cOutput))
            iY = INTEGER(ENTRY(iii + 1, cOutput)).
        IF iX = -1 THEN
            cScore = ENTRY(iii + 2, cOutput).
        ELSE CASE ENTRY(iii + 2, cOutput):
            /* WHEN "{&xiWall}" THEN */
            /* WHEN "{&xiBlock}" THEN */
            WHEN "{&xiPaddle}" THEN
                iXPaddle = iX.
                /* MESSAGE "Paddle" iX iY */
                    /* VIEW-AS ALERT-BOX INFO BUTTONS OK. */
            WHEN "{&xiBall}" THEN
                iXBall = iX.
                /* MESSAGE "Ball" iX iY */
                    /* VIEW-AS ALERT-BOX INFO BUTTONS OK. */
        END CASE.
    END.
    IF iStep MODULO 100 = 0 THEN PUT STREAM sLog UNFORMATTED iStep SKIP ETIME SKIP paintScreen(YES) SKIP(1).
    /* ELSE paintScreen(NO). */
    DISP ETIME iStep cScore.
    IF NOT lAmp1 THEN LEAVE.
    lAmp1 = runProgram(iRam1, iPC1, iRelBase1, IF iXPaddle = iXBall THEN "0" ELSE IF iXPaddle > iXBall THEN "-1" ELSE "1", OUTPUT cOutput). 
    cOutput = SUBSTRING(cOutput, 2).
END.
PUT STREAM sLog UNFORMATTED "THE END" SKIP(1).
PUT STREAM sLog UNFORMATTED iStep SKIP ETIME SKIP paintScreen(YES) SKIP(1).
OUTPUT STREAM sLog CLOSE.

MESSAGE ETIME SKIP cScore
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
90698 
420
---------------------------
Aceptar   Ayuda   
---------------------------
*/
