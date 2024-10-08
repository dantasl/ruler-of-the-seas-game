MACHINE           Results

SETS              CAR

VARIABLES         finish

INVARIANT         finish : iseq(CAR)

INITIALISATION    finish := []

OPERATIONS

finished(rr) =
  PRE rr : CAR & rr /: ran(finish)
  THEN finish := finish <- rr
  END;

rr <-- query(pp) =
  PRE pp : NAT1 & pp <= size(finish)
  THEN rr := finish(pp)
  END;

disqualify(pp) =
  PRE pp : NAT1 & pp <= size(finish)
  THEN finish := (finish /|\ pp-1) ^ (finish \|/ pp)
  END;

ss <-- medals =
  PRE size(finish) >= 3
  THEN ss := finish /|\ 3
  END;

pp <-- position(cc) = 
  PRE cc : CAR & cc : ran(finish)
  THEN
   pp := 1;
   WHILE finish(pp) /= cc DO
     pp := pp + 1
   INVARIANT
     pp : 1..size(finish)
   VARIANT
     size(finish) - pp
   END
  END;

remove(cc) =
  PRE cc : CAR & cc : ran(finish)
  THEN
    VAR pos IN
      pos := 1;
      WHILE finish(pos) /= cc DO
        pos := pos + 1
      INVARIANT
        pos : 1..size(finish)
      VARIANT
        size(finish) - pos
      END;
      finish := (finish /|\ (pos-1)) ^ (finish \|/ pos)
    END
  END

END