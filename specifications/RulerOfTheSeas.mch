MACHINE RulerOfTheSeas
SETS
    PLAYER = {p1, p2, p3, p4};
    ISLAND = {i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12}

CONSTANTS
    MAX_PLAYERS, MIN_PLAYERS, MAX_HAPPINESS

PROPERTIES
    MAX_PLAYERS = 4 & 
    MIN_PLAYERS = 2 &
    MAX_HAPPINESS = 100

VARIABLES
    players, player_coins, player_islands, available_islands,
    turn, island_happiness, turn_completed

INVARIANT
    players <: PLAYER &
    player_coins : players --> NAT &
    player_islands : players --> POW(ISLAND) &
    available_islands <: ISLAND &
    island_happiness : ISLAND +-> (0..MAX_HAPPINESS) &
    turn_completed <: players &
    turn : NAT

INITIALISATION
    players := {} ||
    player_coins := {} ||
    player_islands := {} ||
    available_islands := ISLAND ||
    island_happiness := {} ||
    turn_completed := {} ||
    turn := 0

OPERATIONS
    AddPlayer(p) =
        PRE
            p : PLAYER & card(players) < MAX_PLAYERS & p /: players & turn = 0
        THEN
            players := players \/ {p} ||
            player_coins(p) := 0 ||
            ANY i WHERE i : available_islands THEN
                player_islands(p) := {i} ||
                island_happiness(i) := MAX_HAPPINESS ||
                available_islands := available_islands - {i}
            END
        END;
        
    StartGame =
        PRE
            card(players) >= MIN_PLAYERS & card(players) <= MAX_PLAYERS & turn = 0
        THEN
            turn := 1
        END;

    InvestOnResources(p) =
        PRE
            p : players & p /: turn_completed & turn > 0
        THEN
            VAR remaining_islands
            IN
                remaining_islands := player_islands(p);
                WHILE remaining_islands /= {} DO
                    ANY i WHERE i : remaining_islands THEN
                        player_coins(p) := player_coins(p) + 1;
                        island_happiness(i) := island_happiness(i) - 20;
                        remaining_islands := remaining_islands - {i}
                    END
                INVARIANT
                    remaining_islands <: player_islands(p) & /* Ensures remaining islands are a subset of the player's islands */
                    p : players & /* Ensures `p` remains in the players set */
                    player_coins(p) : NAT & /* Ensures player coins are a natural number */
                    island_happiness : ISLAND +-> (0..MAX_HAPPINESS) /* Ensures valid mapping of island happiness */
                VARIANT
                    card(remaining_islands)
                END
            END ||
            turn_completed := turn_completed \/ {p}
        END;
    
    NextTurn =
        PRE
            card(turn_completed) = card(players) & turn > 0
        THEN
            turn_completed := {} ||
            turn := turn + 1
        END
END
