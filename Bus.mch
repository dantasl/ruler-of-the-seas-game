MACHINE Bus
VARIABLES tickets, passengers
INVARIANT 
    tickets:NATURAL 
    & passengers:NATURAL 
    & tickets <= passengers
    & passengers - tickets <= 5

INITIALISATION 
    tickets, passengers := 0,0
OPERATIONS 
    buy(mm) =
        PRE tickets <= passengers & mm:NATURAL & tickets + mm <= passengers
        THEN tickets := tickets + mm
        END;

    board(nn) =
        PRE nn:NATURAL & passengers - tickets <= 5 & passengers + nn <= tickets + 5
        THEN passengers := passengers + nn
        END;

    double = 
        tickets, passengers := 2*tickets, 2*passengers
END
