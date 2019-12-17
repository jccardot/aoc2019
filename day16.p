/*
--- Part Two ---

Now that your FFT is working, you can decode the real signal.

The real signal is your puzzle input repeated 10000 times. Treat this new signal as a single input list. Patterns are still calculated as before, and 100 phases of FFT are still applied.

The first seven digits of your initial input signal also represent the message offset. The message offset is the location of the eight-digit message in the final output list. Specifically, the message offset indicates the number of digits to skip before reading the eight-digit message. For example, if the first seven digits of your initial input signal were 1234567, the eight-digit message would be the eight digits after skipping 1,234,567 digits of the final output list. Or, if the message offset were 7 and your final output list were 98765432109876543210, the eight-digit message would be 21098765. (Of course, your real message offset will be a seven-digit number, not a one-digit number like 7.)

Here is the eight-digit message in the final output list after 100 phases. The message offset given in each input has been highlighted. (Note that the inputs given below are repeated 10000 times to find the actual starting input lists.)

    03036732577212944063491565474664 becomes 84462026.
    02935109699940807407585447034323 becomes 78725270.
    03081770884921959731165446850517 becomes 53553731.

After repeating your input signal 10000 times and running 100 phases of FFT, what is the eight-digit message embedded in the final output list?

*/

ETIME(YES).

/* DEFINE VARIABLE cInput AS CHARACTER INITIAL "{C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day16.txt}"  NO-UNDO. */
DEFINE VARIABLE cInput AS CHARACTER INITIAL "80871224585914546619083218645595"  NO-UNDO.

DEFINE VARIABLE i         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iInput    AS INTEGER   EXTENT NO-UNDO.
DEFINE VARIABLE iIter     AS INTEGER   NO-UNDO.
DEFINE VARIABLE iLength   AS INTEGER   NO-UNDO.
DEFINE VARIABLE iOutput   AS INTEGER   EXTENT NO-UNDO.
DEFINE VARIABLE iPhase    AS INTEGER   EXTENT 4 INITIAL [0,1,0,-1] NO-UNDO.
DEFINE VARIABLE iPhasePos AS INTEGER   NO-UNDO.
DEFINE VARIABLE j         AS INTEGER   NO-UNDO.
DEFINE VARIABLE k         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iMul AS INTEGER     NO-UNDO.

iLength = LENGTH(cInput).
EXTENT(iInput) = iLength.
EXTENT(iOutput) = iLength.

DO i = iLength TO 1 BY -1:
    iInput[i] = INTEGER(SUBSTRING(cInput,i,1)).
END.

DEFINE VARIABLE ccc AS LONGCHAR   NO-UNDO.

DO iIter = 1 TO 100:
    /* ccc = "". */
    DO i = 1 TO iLength:
        iPhasePos = 2.
        /*
        /* naive solution */
        DO j = i TO iLength:
            IF iPhasePos = 2 OR iPhasePos = 4 THEN /* 1 & 3 are zero */
                iOutput[i] = iOutput[i] + iInput[j] * iPhase[ iPhasePos ].
            ccc = ccc + /* STRING(iInput[j]) + " * " +*/ STRING(iPhase[ iPhasePos ], "+9") /*+ " + "*/.
            IF (j + 1) MOD i = 0 THEN DO:
                iPhasePos = iPhasePos + 1.
                IF iPhasePos > 4 THEN iPhasePos = 1.
            END.
        END.
        */
        j = i.
        DO WHILE TRUE: /* cannot use a variable in BY :( */

            IF i = 1 AND j = 1 THEN iPhasePos = 2.

            iOutput[i] = iOutput[i] + iInput[j] * iPhase[ iPhasePos ].
            /* ccc = ccc + /* STRING(iInput[j]) + " * " +*/ STRING(iPhase[ iPhasePos ], "+9") /*+ " + "*/. */

            IF j MODULO i = i - 1 THEN DO:
                j = j + i + 1.
                IF iPhasePos = 2 THEN
                    iPhasePos = 4.
                ELSE 
                    iPhasePos = 2.
            END.
            ELSE
                j = j + 1.
            IF j > iLength THEN LEAVE.
        END.
        
        iOutput[i] = ABSOLUTE(iOutput[i]) MODULO 10.
        /* ccc = ccc + " = " + STRING(ABSOLUTE(iOutput[i]) MODULO 10) + "~n". */
    END.
    /* MESSAGE STRING(ccc) VIEW-AS ALERT-BOX INFO BUTTONS OK. */
    iInput = iOutput.
    iOutput = 0.
END.

DO i = 1 TO 8:
    ccc = ccc + STRING(iInput[i]).
END.

MESSAGE ETIME SKIP STRING(ccc)
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
46342 
19944447
---------------------------
Aceptar   Ayuda   
---------------------------
*/
