/*
--- Day 4: Secure Container ---

You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.

However, they do remember a few key facts about the password:

    It is a six-digit number.
    The value is within the range given in your puzzle input.
    Two adjacent digits are the same (like 22 in 122345).
    Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).

Other than the range rule, the following are true:

    111111 meets these criteria (double 11, never decreases).
    223450 does not meet these criteria (decreasing pair of digits 50).
    123789 does not meet these criteria (no double).

How many different passwords within the range given in your puzzle input meet these criteria?

*/

ETIME(YES).

DEFINE VARIABLE cDigit1      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cDigit2      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cPassword    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i            AS INTEGER     NO-UNDO.
DEFINE VARIABLE iFrom        AS INTEGER     INITIAL 264793 NO-UNDO.
DEFINE VARIABLE iNbMatches   AS INTEGER     NO-UNDO.
DEFINE VARIABLE iTo          AS INTEGER     INITIAL 803935 NO-UNDO.
DEFINE VARIABLE j            AS INTEGER     NO-UNDO.
DEFINE VARIABLE lDoubleDigit AS LOGICAL     NO-UNDO.

blkPassword:
DO i = iFrom TO iTo:
    ASSIGN
        lDoubleDigit = NO
        cPassword    = STRING(i).
    DO j = 1 TO 5:
        ASSIGN
            cDigit1 = SUBSTRING(cPassword, j,     1)
            cDigit2 = SUBSTRING(cPassword, j + 1, 1).
        IF cDigit1 > cDigit2 THEN NEXT blkPassword.
        IF cDigit1 = cDigit2 THEN lDoubleDigit = YES.
    END.
    IF lDoubleDigit THEN iNbMatches = iNbMatches + 1.
END.

MESSAGE ETIME SKIP iNbMatches
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
2637 
966
---------------------------
Aceptar   Ayuda   
---------------------------
*/

