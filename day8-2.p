/*
--- Part Two ---

Now you're ready to decode the image. The image is rendered by stacking the layers and aligning the pixels with the same positions in each layer. The digits indicate the color of the corresponding pixel: 0 is black, 1 is white, and 2 is transparent.

The layers are rendered with the first layer in front and the last layer in back. So, if a given position has a transparent pixel in the first and second layers, a black pixel in the third layer, and a white pixel in the fourth layer, the final image would have a black pixel at that position.

For example, given an image 2 pixels wide and 2 pixels tall, the image data 0222112222120000 corresponds to the following image layers:

Layer 1: 02
         22

Layer 2: 11
         22

Layer 3: 22
         12

Layer 4: 00
         00

Then, the full image can be found by determining the top visible pixel in each position:

    The top-left pixel is black because the top layer is 0.
    The top-right pixel is white because the top layer is 2 (transparent), but the second layer is 1.
    The bottom-left pixel is white because the top two layers are 2, but the third layer is 1.
    The bottom-right pixel is black because the only visible pixel in that position is 0 (from layer 4).

So, the final image looks like this:

01
10

What message is produced after decoding your image?

*/

ETIME(YES).

DEFINE VARIABLE cData        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cLayer       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cLayer1      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cLayer2      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i            AS INTEGER     NO-UNDO.
DEFINE VARIABLE iLayerLength AS INTEGER     NO-UNDO.
DEFINE VARIABLE iLength      AS INTEGER     NO-UNDO.
DEFINE VARIABLE iPos         AS INTEGER     NO-UNDO.


INPUT FROM C:\Work\aoc\aoc2019\day8.txt.
IMPORT cData.
INPUT CLOSE.

ASSIGN
    iPos         = 1
    iLength      = LENGTH(cData)
    iLayerLength = 25 * 6
    .

cLayer1 = SUBSTRING(cData, iPos, iLayerLength).
iPos = iPos + iLayerLength.
DO WHILE iPos < iLength:
    cLayer2 = SUBSTRING(cData, iPos, iLayerLength).
    iPos = iPos + iLayerLength.

    cLayer = cLayer1.
    DO i = iLayerLength TO 1 BY -1:
        IF SUBSTRING(cLayer1,i,1) = "2" THEN
            SUBSTRING(cLayer,i,1) = SUBSTRING(cLayer2,i,1).
    END.
    cLayer1 = cLayer.
END.

DEFINE VARIABLE cMessage AS CHARACTER   NO-UNDO.
iPos = 1.
DO i = 1 TO 6:
    cMessage = cMessage + SUBSTRING(cLayer, iPos, 25) + "~n".
    iPos = iPos + 25.
END.

MESSAGE ETIME SKIP REPLACE(REPLACE(cMessage, "0", " "), "1", "#")
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Renseignement (Press HELP to view stack trace)
---------------------------
14 
 ##    ## #### #  # ###  
#  #    #    # #  # #  # 
#       #   #  #### #  # 
#       #  #   #  # ###  
#  # #  # #    #  # # #  
 ##   ##  #### #  # #  # 
---------------------------
OK   Aide   
---------------------------
*/

