MACHINE WP

VARIABLES
    aa, bb, cc, ss, tt, ans, cat

SETS
    ODD_EVEN = {odd, even};
    SIZE = {small, medium, large}

INVARIANT         
    aa: NAT 
    & bb: NAT
    & cc: NAT
    & ss:POW(NAT)
    & tt:POW(NAT)
    & ans:ODD_EVEN
    & cat:SIZE

ASSERTIONS
    /*@ label Question_1a */ (aa <= bb - cc);
    /*@ label Question_1b */ (aa <= bb + 1 - cc);
    /*@ label Question_1c */ (1 = 1);
    /*@ label Question_1d */ (1 = 1);
    /*@ label Question_1e */ (bb = card(ss));
    /*@ label Question_1f */ (ss /\ tt = {});
    /*@ label Question_1g */ (aa == bb & aa > 0);
    /*@ label Question_1h */ (aa mod 2 = 0);
    /*@ label Question_1i */ (((aa + 2) div 3) /= 2 & ((aa + 2) div 3) /= 3)
    
INITIALISATION
    aa, bb, cc, ss, tt, ans, cat := 0, 0, 0, {}, {}, even, small

END

