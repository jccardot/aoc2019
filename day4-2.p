/*
--- Part Two ---

An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

Given this additional criterion, but still ignoring the range rule, the following are now true:

    112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
    123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
    111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).

How many different passwords within the range given in your puzzle input meet all of the criteria?

*/

ETIME(YES).

DEFINE VARIABLE cDigit1    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cDigit2    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cPassword  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i          AS INTEGER     NO-UNDO.
DEFINE VARIABLE iFrom      AS INTEGER     INITIAL 264793 NO-UNDO.
DEFINE VARIABLE iNbMatches AS INTEGER     NO-UNDO.
DEFINE VARIABLE iTo        AS INTEGER     INITIAL 803935 NO-UNDO.
DEFINE VARIABLE j          AS INTEGER     NO-UNDO.

blkPassword:
DO i = iFrom TO iTo:

    cPassword = STRING(i).
    DO j = 1 TO 5:
        ASSIGN
            cDigit1 = SUBSTRING(cPassword, j,     1)
            cDigit2 = SUBSTRING(cPassword, j + 1, 1).
        IF cDigit1 > cDigit2 THEN NEXT blkPassword.
    END.

    IF    INDEX(cPassword, "00") > 0 AND INDEX(cPassword, "000") = 0
       OR INDEX(cPassword, "11") > 0 AND INDEX(cPassword, "111") = 0
       OR INDEX(cPassword, "22") > 0 AND INDEX(cPassword, "222") = 0
       OR INDEX(cPassword, "33") > 0 AND INDEX(cPassword, "333") = 0
       OR INDEX(cPassword, "44") > 0 AND INDEX(cPassword, "444") = 0
       OR INDEX(cPassword, "55") > 0 AND INDEX(cPassword, "555") = 0
       OR INDEX(cPassword, "66") > 0 AND INDEX(cPassword, "666") = 0
       OR INDEX(cPassword, "77") > 0 AND INDEX(cPassword, "777") = 0
       OR INDEX(cPassword, "88") > 0 AND INDEX(cPassword, "888") = 0
       OR INDEX(cPassword, "99") > 0 AND INDEX(cPassword, "999") = 0
    THEN
        iNbMatches = iNbMatches + 1.

END.

MESSAGE ETIME SKIP iNbMatches
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
1914 
628
---------------------------
Aceptar   Ayuda   
---------------------------
*/

