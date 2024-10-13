MACHINE 
    Hotelguests
    
SETS 
    ROOM; NAME; REPORT = {present, notpresent}

CONSTANTS         
    sze

PROPERTIES        
    sze : NATURAL1 & card(ROOM) = sze

VARIABLES
    pguests

INVARIANT
    pguests : ROOM +-> NAME

INITIALISATION
    pguests := {}

OPERATIONS

  guestcheckin(rr,nn) =
  PRE rr : ROOM & nn : NAME & rr /: dom(pguests)
  THEN pguests(rr) := nn
  END;

  guestcheckout(rr) = 
  PRE rr : ROOM & rr : dom(pguests)
  THEN pguests := {rr} <<| pguests
  END;

nn <-- guestquery(rr) = 
  PRE rr : ROOM & rr : dom(pguests)
  THEN  nn := pguests(rr)
  END;

rr <-- presentquery(nn) =
  PRE nn : NAME
  THEN IF nn : ran(pguests)
       THEN rr := present
       ELSE rr := notpresent
       END
  END;

guestswap(rr,ss) = 
  PRE rr : ROOM & ss : ROOM & rr : dom(pguests) & ss : dom(pguests)
  THEN pguests := pguests <+ {rr |-> pguests(ss),ss|-> pguests(rr)}
  END

END