/*
--- Part Two ---

It's no good - in this configuration, the amplifiers can't generate a large enough output signal to produce the thrust you'll need. The Elves quickly talk you through rewiring the amplifiers into a feedback loop:

      O-------O  O-------O  O-------O  O-------O  O-------O
0 -+->| Amp A |->| Amp B |->| Amp C |->| Amp D |->| Amp E |-.
   |  O-------O  O-------O  O-------O  O-------O  O-------O |
   |                                                        |
   '--------------------------------------------------------+
                                                            |
                                                            v
                                                     (to thrusters)

Most of the amplifiers are connected as they were before; amplifier A's output is connected to amplifier B's input, and so on. However, the output from amplifier E is now connected into amplifier A's input. This creates the feedback loop: the signal will be sent through the amplifiers many times.

In feedback loop mode, the amplifiers need totally different phase settings: integers from 5 to 9, again each used exactly once. These settings will cause the Amplifier Controller Software to repeatedly take input and produce output many times before halting. Provide each amplifier its phase setting at its first input instruction; all further input/output instructions are for signals.

Don't restart the Amplifier Controller Software on any amplifier during this process. Each one should continue receiving and sending signals until it halts.

All signals sent or received in this process will be between pairs of amplifiers except the very first signal and the very last signal. To start the process, a 0 signal is sent to amplifier A's input exactly once.

Eventually, the software on the amplifiers will halt after they have processed the final loop. When this happens, the last output signal from amplifier E is sent to the thrusters. Your job is to find the largest output signal that can be sent to the thrusters using the new phase settings and feedback loop arrangement.

Here are some example programs:

    Max thruster signal 139629729 (from phase setting sequence 9,8,7,6,5):

    3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
    27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5

    Max thruster signal 18216 (from phase setting sequence 9,7,8,5,6):

    3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
    -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
    53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10

Try every combination of the new phase settings on the amplifier feedback loop. What is the highest signal that can be sent to the thrusters?

*/

ETIME(YES).

DEFINE VARIABLE iRam AS INT64 EXTENT INITIAL [{C:/\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day7.txt}]    NO-UNDO.
/* DEFINE VARIABLE iRam AS INT64 EXTENT INITIAL [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]    NO-UNDO. */
DEFINE VARIABLE iRamInit AS INT64 EXTENT NO-UNDO.

iRamInit = iRam.

FUNCTION ramValue RETURNS INT64 ( iPC AS INTEGER, cMode AS CHARACTER ):    
    RETURN iRam[IF cMode = "1" THEN iPC ELSE iRam[iPC] + 1].
END FUNCTION.

FUNCTION runProgram RETURNS LOGICAL (
    INPUT-OUTPUT iRam AS INT64 EXTENT,
    INPUT-OUTPUT iPc AS INTEGER,
    pcInput AS CHARACTER,
    OUTPUT piOutput AS INT64):

    /* iRam = iRamInit. */

    DEFINE VARIABLE cMode1      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMode2      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMode3      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cOpcode     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE iInputIndex AS INTEGER     INITIAL 1 NO-UNDO.
    DEFINE VARIABLE iNbInput   AS INTEGER     NO-UNDO.

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
                iRam[iRam[iPC + 3] + 1] = iRam[IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1
                    
                    ] + iRam[IF cMode2 = "1" THEN iPC + 2 ELSE iRam[iPC + 2] + 1].
                iPC = iPC + 4.
            END.
            WHEN "02" THEN DO:
                iRam[iRam[iPC + 3] + 1] = iRam[IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1] * iRam[IF cMode2 = "1" THEN iPC + 2 ELSE iRam[iPC + 2] + 1].
                iPC = iPC + 4.
            END.
            WHEN "03" THEN DO: /* input */
                IF iInputIndex > iNbInput THEN RETURN TRUE. /* stop to wait for more input */
                iRam[iRam[iPC + 1] + 1] = INT64(ENTRY(iInputIndex, pcInput)).
                iInputIndex = iInputIndex + 1.
                iPC = iPC + 2.
            END.
            WHEN "04" THEN DO: /* output */
                piOutput = iRam[(IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1)].
                iPC = iPC + 2.
            END.
            WHEN "05" THEN DO: /* jump-if-true */
                IF iRam[(IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1)] <> 0 THEN
                    iPC = iRam[(IF cMode2 = "1" THEN iPC + 2 ELSE iRam[iPC + 2] + 1)] + 1.
                ELSE
                    iPC = iPC + 3.
            END.
            WHEN "06" THEN DO: /* jump-if-false */
                IF iRam[(IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1)] = 0 THEN
                    iPC = iRam[(IF cMode2 = "1" THEN iPC + 2 ELSE iRam[iPC + 2] + 1)] + 1.
                ELSE
                    iPC = iPC + 3.
            END.
            WHEN "07" THEN DO: /* less than */
                iRam[iRam[iPC + 3] + 1] = IF iRam[IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1] < iRam[IF cMode2 = "1" THEN iPC + 2 ELSE iRam[iPC + 2] + 1] THEN 1 ELSE 0.
                iPC = iPC + 4.
            END.
            WHEN "08" THEN DO: /* equals */
                iRam[iRam[iPC + 3] + 1] = IF iRam[IF cMode1 = "1" THEN iPC + 1 ELSE iRam[iPC + 1] + 1] = iRam[IF cMode2 = "1" THEN iPC + 2 ELSE iRam[iPC + 2] + 1] THEN 1 ELSE 0.
                iPC = iPC + 4.
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

DEFINE VARIABLE iMax    AS INT64   NO-UNDO.
DEFINE VARIABLE iOutput AS INT64   NO-UNDO.

DEFINE VARIABLE iPC1 AS INTEGER  NO-UNDO.
DEFINE VARIABLE iPC2 AS INTEGER  NO-UNDO.
DEFINE VARIABLE iPC3 AS INTEGER  NO-UNDO.
DEFINE VARIABLE iPC4 AS INTEGER  NO-UNDO.
DEFINE VARIABLE iPC5 AS INTEGER  NO-UNDO.

DEFINE VARIABLE iRam1 AS INT64   EXTENT NO-UNDO.
DEFINE VARIABLE iRam2 AS INT64   EXTENT NO-UNDO.
DEFINE VARIABLE iRam3 AS INT64   EXTENT NO-UNDO.
DEFINE VARIABLE iRam4 AS INT64   EXTENT NO-UNDO.
DEFINE VARIABLE iRam5 AS INT64   EXTENT NO-UNDO.

DEFINE VARIABLE cParam1 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cParam2 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cParam3 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cParam4 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cParam5 AS CHARACTER   NO-UNDO.

DEFINE VARIABLE lAmp1 AS LOGICAL     NO-UNDO.
DEFINE VARIABLE lAmp2 AS LOGICAL     NO-UNDO.
DEFINE VARIABLE lAmp3 AS LOGICAL     NO-UNDO.
DEFINE VARIABLE lAmp4 AS LOGICAL     NO-UNDO.
DEFINE VARIABLE lAmp5 AS LOGICAL     NO-UNDO.

DEFINE VARIABLE i AS INTEGER     NO-UNDO.
DEFINE VARIABLE j AS INTEGER     NO-UNDO.
DEFINE VARIABLE k AS INTEGER     NO-UNDO.
DEFINE VARIABLE l AS INTEGER     NO-UNDO.
DEFINE VARIABLE m AS INTEGER     NO-UNDO.

DO i = 5 TO 9:
    DO j = 5 TO 9:
        IF j = i THEN NEXT.
        DO k = 5 TO 9:
            IF k = i OR k = j THEN NEXT.
            DO l = 5 TO 9:
                IF l = i OR l = j OR l = k THEN NEXT.
                DO m = 5 TO 9:
                    IF m = i OR m = j OR m = k OR m = l THEN NEXT.

                    ASSIGN
                        iPC1  = 1
                        iPC2  = 1
                        iPC3  = 1
                        iPC4  = 1
                        iPC5  = 1
                        iRam1 = iRamInit
                        iRam2 = iRamInit
                        iRam3 = iRamInit
                        iRam4 = iRamInit
                        iRam5 = iRamInit
                        lAmp1 = YES
                        lAmp2 = YES
                        lAmp3 = YES
                        lAmp4 = YES
                        lAmp5 = YES
                        cParam1 = ""
                        cParam2 = ""
                        cParam3 = ""
                        cParam4 = ""
                        cParam5 = ""
                        .

                    DO WHILE lAmp5:
                        IF cParam1 > "" THEN cParam1 = STRING(iOutput). ELSE cParam1 = STRING(i) + ",0".
                        lAmp1 = runProgram(iRam1, iPC1, cParam1, OUTPUT iOutput).
                        IF cParam2 > "" THEN cParam2 = STRING(iOutput). ELSE cParam2 = STRING(j) +  "," + STRING(iOutput).
                        lAmp2 = runProgram(iRam2, iPC2, cParam2, OUTPUT iOutput).
                        IF cParam3 > "" THEN cParam3 = STRING(iOutput). ELSE cParam3 = STRING(k) +  "," + STRING(iOutput).
                        lAmp3 = runProgram(iRam3, iPC3, cParam3, OUTPUT iOutput).
                        IF cParam4 > "" THEN cParam4 = STRING(iOutput). ELSE cParam4 = STRING(l) +  "," + STRING(iOutput).
                        lAmp4 = runProgram(iRam4, iPC4, cParam4, OUTPUT iOutput).
                        IF cParam5 > "" THEN cParam5 = STRING(iOutput). ELSE cParam5 = STRING(m) +  "," + STRING(iOutput).
                        lAmp5 = runProgram(iRam5, iPC5, cParam5, OUTPUT iOutput).
                    END.
                    /* DISP i j k l m lAmp1 lAmp2 lAmp3 lAmp4 lAmp5 iOutput iMax. */
                    IF iMax < iOutput THEN
                        iMax = iOutput.
                END.
            END.
        END.
    END.
END.

MESSAGE ETIME SKIP iMax
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
4705
3745599
---------------------------
Aceptar   Ayuda   
---------------------------
*/
