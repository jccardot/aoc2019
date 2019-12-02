/*
--- Part Two ---

"Good, the new computer seems to be working correctly! Keep it nearby during this mission - you'll probably use it again. Real Intcode computers support many more features than your new one, but we'll let you know what they are as you need them."

"However, your current priority should be to complete your gravity assist around the Moon. For this mission to succeed, we should settle on some terminology for the parts you've already built."

Intcode programs are given as a list of integers; these values are used as the initial state for the computer's memory. When you run an Intcode program, make sure to start by initializing memory to the program's values. A position in memory is called an address (for example, the first value in memory is at "address 0").

Opcodes (like 1, 2, or 99) mark the beginning of an instruction. The values used immediately after an opcode, if any, are called the instruction's parameters. For example, in the instruction 1,2,3,4, 1 is the opcode; 2, 3, and 4 are the parameters. The instruction 99 contains only an opcode and has no parameters.

The address of the current instruction is called the instruction pointer; it starts at 0. After an instruction finishes, the instruction pointer increases by the number of values in the instruction; until you add more instructions to the computer, this is always 4 (1 opcode + 3 parameters) for the add and multiply instructions. (The halt instruction would increase the instruction pointer by 1, but it halts the program instead.)

"With terminology out of the way, we're ready to proceed. To complete the gravity assist, you need to determine what pair of inputs produces the output 19690720."

The inputs should still be provided to the program by replacing the values at addresses 1 and 2, just like before. In this program, the value placed in address 1 is called the noun, and the value placed in address 2 is called the verb. Each of the two input values will be between 0 and 99, inclusive.

Once the program has halted, its output is available at address 0, also just like before. Each time you try a pair of inputs, make sure you first reset the computer's memory to the values in the program (your puzzle input) - in other words, don't reuse memory from a previous attempt.

Find the input noun and verb that cause the program to produce the output 19690720. What is 100 * noun + verb? (For example, if noun=12 and verb=2, the answer would be 1202.)

*/

ETIME(YES).

DEFINE TEMP-TABLE ttRAM
    FIELD iAddress AS INTEGER
    FIELD iValue AS INTEGER
    INDEX ix IS PRIMARY UNIQUE iAddress.

DEFINE BUFFER ttOpcode  FOR ttRam.
DEFINE BUFFER ttValue1  FOR ttRam.
DEFINE BUFFER ttValue2  FOR ttRam.
DEFINE BUFFER ttAddress FOR ttRam.
                                         
DEFINE VARIABLE i       AS INTEGER     NO-UNDO.
DEFINE VARIABLE cMemory AS CHARACTER   NO-UNDO.
DEFINE VARIABLE iPC     AS INTEGER     NO-UNDO.
DEFINE VARIABLE iMaxAddress AS INTEGER     NO-UNDO.

INPUT FROM C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day2.txt.
IMPORT cMemory.
INPUT CLOSE.

PROCEDURE resetRam:
    EMPTY TEMP-TABLE ttRam.
    iMaxAddress = NUM-ENTRIES(cMemory) - 1.
    DO i = iMaxAddress + 1 TO 1 BY -1:
        CREATE ttRAM.
        ASSIGN
            ttRam.iAddress = i - 1
            ttRam.iValue = INTEGER(ENTRY(i, cMemory)).
    END.
    RELEASE ttRam.
END PROCEDURE.

PROCEDURE runProgram:
    DEFINE INPUT  PARAMETER piNoun AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER piVerb AS INTEGER     NO-UNDO.

    DEFINE VARIABLE i AS INTEGER     NO-UNDO.
    
    /* replace values */
    FIND ttRam WHERE ttRam.iAddress = 1. ttRam.iValue = piNoun.
    FIND ttRam WHERE ttRam.iAddress = 2. ttRam.iValue = piVerb.
    
    /* run the program */
    iPC = 0.
    blkProgram:
    DO WHILE TRUE:
        FIND ttOpcode WHERE ttOpcode.iAddress = iPC.
        CASE ttOpcode.iValue:
            WHEN 1 THEN DO:
                FIND ttRam WHERE ttRam.iAddress = iPC + 1.
                FIND ttValue1 WHERE ttValue1.iAddress = ttRam.iValue.
                FIND ttRam WHERE ttRam.iAddress = iPC + 2.
                FIND ttValue2 WHERE ttValue2.iAddress = ttRam.iValue.
                FIND ttAddress WHERE ttAddress.iAddress = iPC + 3.
                FIND ttRam WHERE ttRam.iAddress = ttAddress.iValue.
                ttRam.iValue = ttValue1.iValue + ttValue2.iValue.
                iPC = iPC + 4.
            END.
            WHEN 2 THEN DO:
                FIND ttRam WHERE ttRam.iAddress = iPC + 1.
                FIND ttValue1 WHERE ttValue1.iAddress = ttRam.iValue.
                FIND ttRam WHERE ttRam.iAddress = iPC + 2.
                FIND ttValue2 WHERE ttValue2.iAddress = ttRam.iValue.
                FIND ttAddress WHERE ttAddress.iAddress = iPC + 3.
                FIND ttRam WHERE ttRam.iAddress = ttAddress.iValue.
                ttRam.iValue = ttValue1.iValue * ttValue2.iValue.
                iPC = iPC + 4.
            END.
            WHEN 99 THEN
                LEAVE blkProgram.
            OTHERWISE DO:
                MESSAGE SUBSTITUTE("Invalid opcode &2 at address &1", ttRam.iAddress, ttRam.iValue)
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
                QUIT.
            END.
        END CASE.
        /*
        DEFINE VARIABLE cRam AS CHARACTER   NO-UNDO.
        cRam = "".
        DO i = iMaxAddress TO 0 BY -1:
            FIND ttRam WHERE ttRam.iAddress = i.
            cRam = STRING(ttRam.iValue) + (IF iPC = i THEN "*" ELSE "") + "," + cRam.
        END.
        MESSAGE "PC:" iPC SKIP "RAM:" cRam
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        */
    END.
END PROCEDURE.

/* let's brute force this */

DEFINE VARIABLE iNoun AS INTEGER     NO-UNDO.
DEFINE VARIABLE iVerb AS INTEGER     NO-UNDO.

blkRun:
DO iNoun = 0 TO 99:
    DO iVerb = 0 TO 99:
        RUN resetRam.
        RUN runProgram(iNoun, iVerb).
        FIND ttRam WHERE ttRam.iAddress = 0.
        IF ttRam.iValue = 19690720 /* expected result */ THEN
            LEAVE blkRun.
    END.
END.

MESSAGE ETIME SKIP 100 * iNoun + iVerb
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
9770
5296
---------------------------
Aceptar   Ayuda   
---------------------------
*/

