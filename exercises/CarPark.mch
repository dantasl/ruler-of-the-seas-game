MACHINE CarPark

VARIABLES
    capacity, parked

INVARIANT         
    capacity : NATURAL & parked : NATURAL & parked <= capacity

INITIALISATION    
    capacity, parked := 10,0

OPERATIONS

enter = 
   PRE parked + 1 <= capacity
   THEN parked := parked + 1
    END;

leave =
   PRE parked > 0
   THEN parked := parked - 1
   END;

nn <-- query=
   nn := parked

END

