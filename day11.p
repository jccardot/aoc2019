/*
--- Day 11: Space Police ---

On the way to Jupiter, you're pulled over by the Space Police.

"Attention, unmarked spacecraft! You are in violation of Space Law! All spacecraft must have a clearly visible registration identifier! You have 24 hours to comply or be sent to Space Jail!"

Not wanting to be sent to Space Jail, you radio back to the Elves on Earth for help. Although it takes almost three hours for their reply signal to reach you, they send instructions for how to power up the emergency hull painting robot and even provide a small Intcode program (your puzzle input) that will cause it to paint your ship appropriately.

There's just one problem: you don't have an emergency hull painting robot.

You'll need to build a new emergency hull painting robot. The robot needs to be able to move around on the grid of square panels on the side of your ship, detect the color of its current panel, and paint its current panel black or white. (All of the panels are currently black.)

The Intcode program will serve as the brain of the robot. The program uses input instructions to access the robot's camera: provide 0 if the robot is over a black panel or 1 if the robot is over a white panel. Then, the program will output two values:

    First, it will output a value indicating the color to paint the panel the robot is over: 0 means to paint the panel black, and 1 means to paint the panel white.
    Second, it will output a value indicating the direction the robot should turn: 0 means it should turn left 90 degrees, and 1 means it should turn right 90 degrees.

After the robot turns, it should always move forward exactly one panel. The robot starts facing up.

The robot will continue running for a while like this and halt when it is finished drawing. Do not restart the Intcode computer inside the robot during this process.

For example, suppose the robot is about to start running. Drawing black panels as ., white panels as #, and the robot pointing the direction it is facing (< ^ > v), the initial state and region near the robot looks like this:

.....
.....
..^..
.....
.....

The panel under the robot (not visible here because a ^ is shown instead) is also black, and so any input instructions at this point should be provided 0. Suppose the robot eventually outputs 1 (paint white) and then 0 (turn left). After taking these actions and moving forward one panel, the region now looks like this:

.....
.....
.<#..
.....
.....

Input instructions should still be provided 0. Next, the robot might output 0 (paint black) and then 0 (turn left):

.....
.....
..#..
.v...
.....

After more outputs (1,0, 1,0):

.....
.....
..^..
.##..
.....

The robot is now back where it started, but because it is now on a white panel, input instructions should be provided 1. After several more outputs (0,1, 1,0, 1,0), the area looks like this:

.....
..<#.
...#.
.##..
.....

Before you deploy the robot, you should probably have an estimate of the area it will cover: specifically, you need to know the number of panels it paints at least once, regardless of color. In the example above, the robot painted 6 panels at least once. (It painted its starting panel twice, but that panel is still only counted once; it also never painted the panel it ended on.)

Build a new emergency hull painting robot and run the Intcode program on it. How many panels does it paint at least once?

*/

ETIME(YES).

DEFINE VARIABLE iRam AS INT64 EXTENT INITIAL [{C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day11.txt}]    NO-UNDO.
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
    cParam1   = "0"
    .

DO i = EXTENT(iRamInit) TO 1 BY -1:
    iRam1[i] = iRamInit[i].
END.

&GLOBAL-DEFINE xiWhite 1
&GLOBAL-DEFINE xiBlack 0
&GLOBAL-DEFINE xiLeft  0
&GLOBAL-DEFINE xiRight 1
&GLOBAL-DEFINE xiUp    2
&GLOBAL-DEFINE xiDown  3

DEFINE VARIABLE iColor     AS INTEGER   NO-UNDO.
DEFINE VARIABLE iCount     AS INTEGER   NO-UNDO.
DEFINE VARIABLE iDirection AS INTEGER   INITIAL {&xiUp} NO-UNDO.
DEFINE VARIABLE iTurn      AS INTEGER   NO-UNDO.
DEFINE VARIABLE iX         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iY         AS INTEGER   NO-UNDO.

DEFINE TEMP-TABLE ttPanel NO-UNDO 
 FIELD iX     AS INTEGER  
 FIELD iY     AS INTEGER  
 FIELD iColor AS INTEGER  INITIAL ?
 INDEX ixy IS PRIMARY UNIQUE iX iY.

DO WHILE lAmp1:
    lAmp1 = runProgram(iRam1, iPC1, iRelBase1, cParam1, OUTPUT cOutput).
    ASSIGN
        cOutput = SUBSTRING(cOutput, 2)
        iColor = INTEGER(ENTRY(1, cOutput))
        iTurn  = INTEGER(ENTRY(2, cOutput)).
    /* DISP iCount SKIP ix iy iDirection SKIP iColor iTurn. */
    FIND ttPanel WHERE ttPanel.iX = iX AND ttPanel.iY = iY NO-ERROR.
    IF NOT AVAILABLE ttPanel THEN DO:
        CREATE ttPanel.
        ASSIGN
            ttPanel.iX = iX
            ttPanel.iY = iY.
        iCount = iCount + 1.
    END.
    ttPanel.iColor = iColor.
    CASE iTurn:
        WHEN {&xiLeft} THEN DO:
            CASE iDirection:
                WHEN {&xiUp} THEN DO:
                    iX = iX - 1.
                    iDirection = {&xiLeft}.
                END.
                WHEN {&xiLeft} THEN DO:
                    iY = iY + 1.
                    iDirection = {&xiDown}.
                END.
                WHEN {&xiDown} THEN DO:
                    iX = iX + 1.
                    iDirection = {&xiRight}.
                END.
                WHEN {&xiRight} THEN DO:
                    iY = iY - 1.
                    iDirection = {&xiUp}.
                END.
            END CASE.
        END.
        WHEN {&xiRight} THEN DO:
            CASE iDirection:
                WHEN {&xiUp} THEN DO:
                    iX = iX + 1.
                    iDirection = {&xiRight}.
                END.
                WHEN {&xiRight} THEN DO:
                    iY = iY + 1.
                    iDirection = {&xiDown}.
                END.
                WHEN {&xiDown} THEN DO:
                    iX = iX - 1.
                    iDirection = {&xiLeft}.
                END.
                WHEN {&xiLeft} THEN DO:
                    iY = iY - 1.
                    iDirection = {&xiUp}.
                END.
            END CASE.
        END.
    END CASE.
    FIND ttPanel WHERE ttPanel.iX = iX AND ttPanel.iY = iY NO-ERROR.
    IF AVAILABLE ttPanel AND ttPanel.iColor = {&xiWhite} THEN
        cParam1 = "1".
    ELSE
        cParam1 = "0".
END.

MESSAGE ETIME SKIP iCount
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
237072 
2041
---------------------------
Aceptar   Ayuda   
---------------------------
*/
