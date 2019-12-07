/*
--- Day 7: Amplification Circuit ---

Based on the navigational maps, you're going to need to send more power to your ship's thrusters to reach Santa in time. To do this, you'll need to configure a series of amplifiers already installed on the ship.

There are five amplifiers connected in series; each one receives an input signal and produces an output signal. They are connected such that the first amplifier's output leads to the second amplifier's input, the second amplifier's output leads to the third amplifier's input, and so on. The first amplifier's input value is 0, and the last amplifier's output leads to your ship's thrusters.

    O-------O  O-------O  O-------O  O-------O  O-------O
0 ->| Amp A |->| Amp B |->| Amp C |->| Amp D |->| Amp E |-> (to thrusters)
    O-------O  O-------O  O-------O  O-------O  O-------O

The Elves have sent you some Amplifier Controller Software (your puzzle input), a program that should run on your existing Intcode computer. Each amplifier will need to run a copy of the program.

When a copy of the program starts running on an amplifier, it will first use an input instruction to ask the amplifier for its current phase setting (an integer from 0 to 4). Each phase setting is used exactly once, but the Elves can't remember which amplifier needs which phase setting.

The program will then call another input instruction to get the amplifier's input signal, compute the correct output signal, and supply it back to the amplifier with an output instruction. (If the amplifier has not yet received an input signal, it waits until one arrives.)

Your job is to find the largest output signal that can be sent to the thrusters by trying every possible combination of phase settings on the amplifiers. Make sure that memory is not shared or reused between copies of the program.

For example, suppose you want to try the phase setting sequence 3,1,2,4,0, which would mean setting amplifier A to phase setting 3, amplifier B to setting 1, C to 2, D to 4, and E to 0. Then, you could determine the output signal that gets sent from amplifier E to the thrusters with the following steps:

    Start the copy of the amplifier controller software that will run on amplifier A. At its first input instruction, provide it the amplifier's phase setting, 3. At its second input instruction, provide it the input signal, 0. After some calculations, it will use an output instruction to indicate the amplifier's output signal.
    Start the software for amplifier B. Provide it the phase setting (1) and then whatever output signal was produced from amplifier A. It will then produce a new output signal destined for amplifier C.
    Start the software for amplifier C, provide the phase setting (2) and the value from amplifier B, then collect its output signal.
    Run amplifier D's software, provide the phase setting (4) and input value, and collect its output signal.
    Run amplifier E's software, provide the phase setting (0) and input value, and collect its output signal.

The final output signal from amplifier E would be sent to the thrusters. However, this phase setting sequence may not have been the best one; another sequence might have sent a higher signal to the thrusters.

Here are some example programs:

    Max thruster signal 43210 (from phase setting sequence 4,3,2,1,0):

    3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0

    Max thruster signal 54321 (from phase setting sequence 0,1,2,3,4):

    3,23,3,24,1002,24,10,24,1002,23,-1,23,
    101,5,23,23,1,24,23,23,4,23,99,0,0

    Max thruster signal 65210 (from phase setting sequence 1,0,4,3,2):

    3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
    1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0

Try every combination of phase settings on the amplifiers. What is the highest signal that can be sent to the thrusters?

*/

ETIME(YES).

DEFINE VARIABLE iRam AS INT64 EXTENT INITIAL [{C:/\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day7.txt}]    NO-UNDO.
/* DEFINE VARIABLE iRam AS INT64 EXTENT INITIAL [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]    NO-UNDO. */
DEFINE VARIABLE iRamInit AS INT64 EXTENT NO-UNDO.

iRamInit = iRam.

FUNCTION ramValue RETURNS INT64 ( iPC AS INTEGER, cMode AS CHARACTER ):    
    RETURN iRam[IF cMode = "1" THEN iPC ELSE iRam[iPC] + 1].
END FUNCTION.

FUNCTION runProgram RETURNS INT64 (
    pcInput AS CHARACTER,
    OUTPUT piOutput AS INT64):

    iRam = iRamInit.

    DEFINE VARIABLE cMode1      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMode2      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMode3      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cOpcode     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE iInputIndex AS INTEGER     INITIAL 1 NO-UNDO.
    DEFINE VARIABLE iPC         AS INTEGER     NO-UNDO.

    iPC = 1.

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

    RETURN iRam[1].

END FUNCTION.

DEFINE VARIABLE iMax    AS INT64   NO-UNDO.
DEFINE VARIABLE iOutput AS INT64   NO-UNDO.

DEFINE VARIABLE i AS INTEGER     NO-UNDO.
DEFINE VARIABLE j AS INTEGER     NO-UNDO.
DEFINE VARIABLE k AS INTEGER     NO-UNDO.
DEFINE VARIABLE l AS INTEGER     NO-UNDO.
DEFINE VARIABLE m AS INTEGER     NO-UNDO.

DO i = 0 TO 4:
    DO j = 0 TO 4:
        IF j = i THEN NEXT.
        DO k = 0 TO 4:
            IF k = i OR k = j THEN NEXT.
            DO l = 0 TO 4:
                IF l = i OR l = j OR l = k THEN NEXT.
                DO m = 0 TO 4:
                    IF m = i OR m = j OR m = k OR m = l THEN NEXT.

                    runProgram(STRING(i) + ",0", OUTPUT iOutput).
                    runProgram(STRING(j) +  "," + STRING(iOutput), OUTPUT iOutput).
                    runProgram(STRING(k) +  "," + STRING(iOutput), OUTPUT iOutput).
                    runProgram(STRING(l) +  "," + STRING(iOutput), OUTPUT iOutput).
                    runProgram(STRING(m) +  "," + STRING(iOutput), OUTPUT iOutput).

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
595 
440880
---------------------------
Aceptar   Ayuda   
---------------------------
*/
