/*
--- Day 8: Space Image Format ---

The Elves' spirits are lifted when they realize you have an opportunity to reboot one of their Mars rovers, and so they are curious if you would spend a brief sojourn on Mars. You land your ship near the rover.

When you reach the rover, you discover that it's already in the process of rebooting! It's just waiting for someone to enter a BIOS password. The Elf responsible for the rover takes a picture of the password (your puzzle input) and sends it to you via the Digital Sending Network.

Unfortunately, images sent via the Digital Sending Network aren't encoded with any normal encoding; instead, they're encoded in a special Space Image Format. None of the Elves seem to remember why this is the case. They send you the instructions to decode it.

Images are sent as a series of digits that each represent the color of a single pixel. The digits fill each row of the image left-to-right, then move downward to the next row, filling rows top-to-bottom until every pixel of the image is filled.

Each image actually consists of a series of identically-sized layers that are filled in this way. So, the first digit corresponds to the top-left pixel of the first layer, the second digit corresponds to the pixel to the right of that on the same layer, and so on until the last digit, which corresponds to the bottom-right pixel of the last layer.

For example, given an image 3 pixels wide and 2 pixels tall, the image data 123456789012 corresponds to the following image layers:

Layer 1: 123
         456

Layer 2: 789
         012

The image you received is 25 pixels wide and 6 pixels tall.

To make sure the image wasn't corrupted during transmission, the Elves would like you to find the layer that contains the fewest 0 digits. On that layer, what is the number of 1 digits multiplied by the number of 2 digits?

*/

ETIME(YES).

DEFINE VARIABLE cData     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cLayer    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cLayerMin AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i         AS INTEGER     NO-UNDO.
DEFINE VARIABLE iCount    AS INTEGER     NO-UNDO.
DEFINE VARIABLE iCount1   AS INTEGER     NO-UNDO.
DEFINE VARIABLE iCount2   AS INTEGER     NO-UNDO.
DEFINE VARIABLE iLength   AS INTEGER     NO-UNDO.
DEFINE VARIABLE iMin      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iPos      AS INTEGER     NO-UNDO.


INPUT FROM C:\Work\aoc\aoc2019\day8.txt.
IMPORT cData.
INPUT CLOSE.

ASSIGN
    iPos    = 1
    iMin    = 25 * 6 + 1
    iLength = LENGTH(cData).

DO WHILE iPos < iLength:
    cLayer = SUBSTRING(cData, iPos, 25 * 6).
    iCount = 0.
    DO i = 25 * 6 TO 1 BY -1:
        IF SUBSTRING(cLayer,i,1) = "0" THEN
            iCount = iCount + 1.
    END.
    IF iCount < iMin THEN ASSIGN
        iMin      = iCount
        cLayerMin = cLayer.
    iPos = iPos + 25 * 6.
END.

DO i = 25 * 6 TO 1 BY -1:
    IF SUBSTRING(cLayerMin,i,1) = "1" THEN
        iCount1 = iCount1 + 1.
    ELSE IF SUBSTRING(cLayerMin,i,1) = "2" THEN
        iCount2 = iCount2 + 1.
END.

MESSAGE ETIME iCount1 * iCount2
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Renseignement (Press HELP to view stack trace)
---------------------------
11 2159
---------------------------
OK   Aide   
---------------------------
*/

