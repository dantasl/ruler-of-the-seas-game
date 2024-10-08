MACHINE Reading

SETS
    READER; 
    BOOK = {book1, book2, book3}; 
    COPY = {copy1, copy2, copy3}; 
    RESPONSE = {yes, no}

VARIABLES         
    hasread, reading, books, copies, copyof

INVARIANT         
    hasread : READER <-> BOOK 
    & reading : READER >+> COPY 
    & (reading ; copyof) /\ hasread = {}
    & books <: BOOK
    & copies <: COPY
    & copyof : copies -->> books

INITIALISATION    
    hasread := {} || reading := {} ||
    books := {} ||
    copies := {} ||
    copyof := {}

OPERATIONS

addBook(bb,cc) =
  PRE bb : BOOK & cc : COPY & bb /: books & cc /: copies
  THEN books := books \/ {bb};
       copies := copies \/ {cc};
       copyof := copyof \/ {cc |-> bb}
  END;

addCopy(cc,bb) = 
  PRE cc : COPY & bb : books & cc /: copies
  THEN copies := copies \/ {cc};
       copyof := copyof \/ {cc |-> bb}
  END;

start(rr,cc) =
  PRE rr : READER 
      & cc : COPY 
      & copyof(cc) /: hasread[{rr}]
      & rr /: dom(reading) 
      & cc /: ran(reading)
  THEN reading := reading \/ {rr |-> cc}
  END;

finished(rr,cc) =
  PRE rr : READER 
      & cc : COPY 
      & rr:dom(reading) 
      & cc = reading(rr)
  THEN hasread := hasread \/ {rr |-> copyof(cc)}
       || reading := {rr} <<| reading
  END;

resp <-- precurrentquery(rr) =
  PRE rr : READER
  THEN
    IF rr : dom(reading)
    THEN resp := yes
    ELSE resp := no
    END
  END;

bb <-- currentquery(rr) =
  PRE rr : READER & rr : dom(reading)
  THEN bb := copyof(reading(rr))
  END;

resp <-- hasreadquery(rr,bb) =
  PRE rr : READER & bb : BOOK
  THEN
    IF bb : hasread[{rr}]
    THEN resp := yes
    ELSE resp := no
    END
  END

END