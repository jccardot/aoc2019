/*
You now have a complete Intcode computer.

Finally, you can lock on to the Ceres distress signal! You just need to boost your sensors using the BOOST program.

The program runs in sensor boost mode by providing the input instruction the value 2. Once run, it will boost the sensors automatically, but it might take a few seconds to complete the operation on slower hardware. In sensor boost mode, the program will output a single value: the coordinates of the distress signal.

Run the BOOST program in sensor boost mode. What are the coordinates of the distress signal?

*/

ETIME(YES).

DEFINE VARIABLE iRam AS INT64 EXTENT INITIAL [{C:/\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day9.txt}]    NO-UNDO.
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
    cParam1   = "2"
    .

DO i = EXTENT(iRamInit) TO 1 BY -1:
    iRam1[i] = iRamInit[i].
END.

lAmp1 = runProgram(iRam1, iPC1, iRelBase1, cParam1, OUTPUT cOutput).
cOutput = SUBSTRING(cOutput, 2).

MESSAGE ETIME SKIP cOutput
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
1480540 
32869
---------------------------
Aceptar   Ayuda   
---------------------------
*/
