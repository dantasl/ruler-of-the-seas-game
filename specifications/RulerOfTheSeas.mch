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
    island_happiness : ISLAND --> (0..MAX_HAPPINESS) &
    turn_completed <: players &
    turn : NAT

INITIALISATION
    players := {} ||
    player_coins := {} ||
    player_islands := {} ||
    available_islands := ISLAND ||
    island_happiness := ISLAND * {MAX_HAPPINESS} ||
    turn_completed := {} ||
    turn := 0

OPERATIONS
    AddPlayer(p) =
        PRE
            p : PLAYER & card(players) < MAX_PLAYERS &
            p /: players &
            turn = 0
        THEN
            players := players \/ {p} ||
            player_coins(p) := 2 ||
            ANY i WHERE i : available_islands THEN
                player_islands(p) := {i} ||
                available_islands := available_islands - {i}
            END
        END;
        
    StartGame =
        PRE
            card(players) >= MIN_PLAYERS &
            card(players) <= MAX_PLAYERS &
            turn = 0
        THEN
            turn := 1
        END;
    
    AcquireIsland(p) =
        PRE
            p : players &
            p /: turn_completed &
            card(available_islands) > 0 &
            turn > 0 &
            player_coins(p) >= 3
        THEN
            player_coins(p) := player_coins(p) - 3 ||
            ANY i WHERE i : available_islands THEN
                player_islands(p) := player_islands(p) \/ {i} ||
                available_islands := available_islands - {i} ||
                island_happiness(i) := MAX_HAPPINESS / 2
            END ||
            turn_completed := turn_completed \/ {p}
        END;
    
    InvestOnResources(p) =
        PRE
            p : players &
            p /: turn_completed &
            turn > 0
        THEN
            VAR
                remaining_islands
            IN
                player_coins(p) := player_coins(p) + card(player_islands(p));
                remaining_islands := player_islands(p);
                WHILE remaining_islands /= {} DO
                    ANY i WHERE i : remaining_islands THEN
                        IF island_happiness(i) - 20 < 0 THEN
                            player_islands(p) := player_islands(p) - {i};
                            available_islands := available_islands \/ {i}
                        ELSE
                            island_happiness(i) := island_happiness(i) - 20
                        END;
                        remaining_islands := remaining_islands - { i }
                    END
                INVARIANT
                    remaining_islands <: player_islands(p)
                VARIANT
                    card(remaining_islands)
                END;
                turn_completed := turn_completed \/ {p}
            END
        END;

    InvestOnHappiness(p) =
        PRE
            p : players &
            p /: turn_completed &
            player_coins(p) >= card(player_islands(p)) &
            turn > 0
        THEN
            VAR
                remaining_islands
            IN
                player_coins(p) := player_coins(p) - card(player_islands(p));
                remaining_islands := player_islands(p);
                WHILE remaining_islands /= {} DO
                    ANY i WHERE i : remaining_islands THEN
                        IF island_happiness(i) + 20 > MAX_HAPPINESS THEN
                            island_happiness(i) := MAX_HAPPINESS
                        ELSE
                            island_happiness(i) := island_happiness(i) + 20
                        END;
                        remaining_islands := remaining_islands - { i }
                    END
                INVARIANT
                    remaining_islands <: player_islands(p)
                VARIANT
                    card(remaining_islands)
                END;
                turn_completed := turn_completed \/ {p}
            END
        END;
    
    AttackPlayer(attacker, victim) =
        PRE
            attacker : players &
            victim : players &
            attacker /= victim &
            player_coins(attacker) >= 4
        THEN
            VAR
                attacker_happiness, victim_happiness
            IN
                player_coins(attacker) := player_coins(attacker) - 4;
                attacker_happiness := SIGMA(i).(i : player_islands(attacker) | island_happiness(i));
                victim_happiness := SIGMA(i).(i : player_islands(victim) | island_happiness(i));
                IF card(player_islands(attacker)) > card(player_islands(victim)) & attacker_happiness > victim_happiness THEN
                    ANY i WHERE i : player_islands(victim) THEN
                        player_islands(attacker) := player_islands(attacker) \/ {i};
                        player_islands(victim) := player_islands(victim) - {i};
                        island_happiness(i) := 80
                    END
                ELSIF card(player_islands(attacker)) > card(player_islands(victim)) & attacker_happiness < victim_happiness THEN
                    ANY i WHERE i : player_islands(victim) THEN
                        player_islands(attacker) := player_islands(attacker) \/ {i};
                        player_islands(victim) := player_islands(victim) - {i};
                        island_happiness(i) := 20
                    END
                ELSE
                    ANY dice_attacker, dice_victim WHERE dice_attacker : 1..6 & dice_victim : 1..6 THEN
                        IF dice_attacker > dice_victim THEN
                            ANY i WHERE i : player_islands(victim) THEN
                                player_islands(attacker) := player_islands(attacker) \/ {i};
                                player_islands(victim) := player_islands(victim) - {i};
                                island_happiness(i) := 50
                            END
                        ELSE
                            ANY i WHERE i : player_islands(attacker) THEN
                                player_islands(victim) := player_islands(victim) \/ {i};
                                player_islands(attacker) := player_islands(attacker) - {i};
                                island_happiness(i) := 50
                            END
                        END
                    END
                END;
                turn_completed := turn_completed \/ {attacker}
            END
        END;

    NextTurn =
        PRE
            card(turn_completed) = card(players) & turn > 0
        THEN
            VAR
                remaining_players
            IN
                remaining_players := players;
                WHILE remaining_players /= {} DO
                    ANY i WHERE i : remaining_players THEN
                        player_coins(i) := player_coins(i) + 1;
                        remaining_players := remaining_players - { i }
                    END
                INVARIANT
                    remaining_players <: players
                VARIANT
                    card(remaining_players)
                END;
                turn_completed := {};
                turn := turn + 1
            END
        END
END