MACHINE
    Paperround

VARIABLES
    papers, magazines

INVARIANT
    papers <: 1..163 
    & magazines <: papers 
    & card(papers) <= 60
    & 2 * card(magazines) <= card(papers)

INITIALISATION
    papers := {} || magazines := {}

OPERATIONS

addpaper(hh) =
    PRE hh : 1..163 & card(papers) < 60
    THEN papers := papers \/ {hh}
    END;

addmagazine(hh) =
    PRE hh : papers & 2 * card(magazines) + 1 < card(papers) & card(papers) > 1
    THEN magazines := magazines \/ {hh} 
    END;

removehouse(hh) =
    PRE hh : papers & hh /: magazines & card(papers) > 2 * card(magazines)
    THEN papers := papers - {hh}
    END;

remove(hh) =
    PRE hh : 1..163
    THEN papers := papers - {hh} || magazines := magazines - {hh}
    END

END
