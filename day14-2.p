/*
--- Part Two ---

After collecting ORE for a while, you check your cargo hold: 1 trillion (1000000000000) units of ORE.

With that much ore, given the examples above:

    The 13312 ORE-per-FUEL example could produce 82892753 FUEL.
    The 180697 ORE-per-FUEL example could produce 5586022 FUEL.
    The 2210736 ORE-per-FUEL example could produce 460664 FUEL.

Given 1 trillion ORE, what is the maximum amount of FUEL you can produce?

*/

ETIME(YES).

DEFINE TEMP-TABLE ttReaction NO-UNDO
 FIELD cInput    AS CHARACTER   FORMAT "X(30)"
 FIELD cChemical AS CHARACTER  
 FIELD iQty      AS INT64    
 INDEX ix cChemical.

DEFINE TEMP-TABLE ttChemical NO-UNDO
 FIELD cChemical AS CHARACTER
 FIELD iQty      AS INT64
 INDEX ix IS PRIMARY UNIQUE cChemical.

DEFINE VARIABLE cLine AS CHARACTER   NO-UNDO.
DEFINE VARIABLE iOre  AS INT64       NO-UNDO.

INPUT FROM C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day14.txt.
REPEAT:
    IMPORT UNFORMATTED cLine.
    IF cLine = "" THEN LEAVE.
    CREATE ttReaction.
    ASSIGN
        ttReaction.cInput    = REPLACE(REPLACE(SUBSTRING(cLine, 1, INDEX(cLine, "=>") - 2), ", ", ","), " ", ",")
        ttReaction.cChemical = SUBSTRING(cLine, INDEX(cLine, "=>") + 3)
        ttReaction.iQty      = INTEGER(ENTRY(1, ttReaction.cChemical, " "))
        ttReaction.cChemical = ENTRY(2, ttReaction.cChemical, " ")
        .
END.
INPUT CLOSE.

CREATE ttChemical.
ASSIGN ttChemical.cChemical = "ORE"
       ttChemical.iQty      = 0.

FUNCTION react RETURNS INTEGER ( cOutputChemical AS CHARACTER, iOutputChemical AS INT64 ):    
    DEFINE VARIABLE iTotal AS INTEGER     NO-UNDO.

    DEFINE BUFFER ttReaction FOR ttReaction.
    DEFINE BUFFER ttChemical FOR ttChemical.

    DEFINE VARIABLE cChemical AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i         AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iChemical AS INT64       NO-UNDO.
    DEFINE VARIABLE iMult     AS INT64       NO-UNDO.
    /* DEFINE VARIABLE iMult2     AS INTEGER     NO-UNDO. */

    /* PUT UNFORMATTED SUBSTITUTE("Want &1 &2~n", iOutputChemical, cOutputChemical). */

    FIND ttReaction WHERE ttReaction.cChemical = cOutputChemical.
    /* how many times do we need to run this reaction */
    IF iOutputChemical MODULO ttReaction.iQty = 0 THEN
        iMult = iOutputChemical / ttReaction.iQty.
    ELSE
        iMult = TRUNCATE(iOutputChemical / ttReaction.iQty, 0) + 1.
    /* iMult = 1. */
    /* DO WHILE iMult * ttReaction.iQty < iOutputChemical: */
        /* iMult = iMult + 1. */
    /* END. */
    /* IF iMult <> iMult2 THEN */
        /* PUT UNFORMATTED SUBSTITUTE("ERROR wanted:&1 react:&2 - &3 <> &4~n", iOutputChemical, ttReaction.iQty, iMult, iMult2). */

    /* PUT UNFORMATTED SUBSTITUTE("React &1 times: &2 => &3 &4 ~n", iMult, ttReaction.cInput, ttReaction.iQty, ttReaction.cChemical). */

    DO i = 1 TO NUM-ENTRIES(ttReaction.cInput) BY 2:
        ASSIGN
            iChemical = INTEGER(ENTRY(i, ttReaction.cInput))
            cChemical = ENTRY(i + 1, ttReaction.cInput).
        FIND ttChemical WHERE ttChemical.cChemical = cChemical NO-ERROR.
        IF NOT AVAILABLE ttChemical THEN DO:
            CREATE ttChemical.
            ASSIGN ttChemical.cChemical = cChemical.
        END.
        /* produce or consume the output chemical */
        IF ttChemical.cChemical = "ORE" THEN DO:
            ttChemical.iQty = ttChemical.iQty + iChemical * iMult. /* consume ORE */
            iOre = iOre + iChemical * iMult.
        END.
        ELSE IF ttChemical.iQty < iChemical * iMult THEN DO: /* produce then consume */
            /* PUT UNFORMATTED SUBSTITUTE("Needs &1 &2 - left: &3~n", iChemical * iMult, cChemical, ttChemical.iQty). */
            react(cChemical, iChemical * iMult - ttChemical.iQty).
            ttChemical.iQty = ttChemical.iQty - iChemical * iMult.
        END.
        ELSE DO: /* only consume */
            ttChemical.iQty = ttChemical.iQty - iChemical * iMult.
        END.
    END.
    FIND ttChemical WHERE ttChemical.cChemical = cOutputChemical NO-ERROR.
    IF NOT AVAILABLE ttChemical THEN DO:
        CREATE ttChemical.
        ASSIGN ttChemical.cChemical = cOutputChemical.
    END.
    ttChemical.iQty = ttChemical.iQty + ttReaction.iQty * iMult.

    /* PUT UNFORMATTED SUBSTITUTE("After reaction: &1 - &2 (ORE: &3)~n", ttChemical.cChemical, ttChemical.iQty, iOre). */
END FUNCTION.

/* OUTPUT TO C:\User\JCCARDOT\Perso\Travail\aoc\aoc2019\day14.log. */
/* react("FUEL", 3061522). */
react("FUEL", 1).
/* OUTPUT CLOSE. */

FIND ttChemical WHERE ttChemical.cChemical = "ORE".

/* let's dichotomize */
DEFINE VARIABLE iFrom  AS INTEGER   INITIAL 1 NO-UNDO.
DEFINE VARIABLE iTo    AS INTEGER   NO-UNDO.
DEFINE VARIABLE iMid AS INTEGER     NO-UNDO.
DEFINE VARIABLE iTotal AS INTEGER   NO-UNDO.

iTo = 1000000000000 / ttChemical.iQty * 2.

iMid = iFrom + (iTo - iFrom) / 2.
react("FUEL",  iMid).
DO WHILE TRUE:
    /* DISP iFrom iMid iTo. */
    IF ttChemical.iQty > 1000000000000 THEN 
        iTo = iMid.
    ELSE IF ttChemical.iQty < 1000000000000 THEN 
        iFrom = iMid.
    iMid = iFrom + (iTo - iFrom) / 2.
    EMPTY TEMP-TABLE ttChemical.
    CREATE ttChemical.
    ASSIGN ttChemical.cChemical = "ORE"
           ttChemical.iQty      = 0.
    react("FUEL",  iMid).
    FIND ttChemical WHERE ttChemical.cChemical = "ORE".
    IF iTo - iFrom <= 1 THEN LEAVE.
END.

IF iTo - iFrom = 1 AND
   iMid = iTo AND
   ttChemical.iQty > 1000000000000 THEN
        iMid = iFrom.

MESSAGE ETIME SKIP /*ttChemical.iQty SKIP 1000000000000 SKIP*/ iMid
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
/*
---------------------------
Information (Press HELP to view stack trace)
---------------------------
1099 
3061522
---------------------------
Aceptar   Ayuda   
---------------------------
*/
    
