MACHINE RulerOfTheSeas
SEES RulerOfTheSeas_Context

VARIABLES
    players, player_coins, player_islands, available_islands,
    turn, island_happiness, turn_completed

INVARIANT
    players <: PLAYER &
    card(players) <= MAX_PLAYERS &
    player_coins : players --> NAT &
    player_islands : players --> POW(ISLAND) &
    available_islands <: ISLAND &
    island_happiness : ISLAND --> (0..MAX_HAPPINESS) &
    turn_completed <: players &
    turn : NAT &
    // No player has the same island as another player
    !p1, p2.(p1 : players & p2 : players & p1 /= p2 => player_islands(p1) /\ player_islands(p2) = {}) & 
    // No player has an island that is available
    UNION pp.(pp : dom(player_islands) | player_islands(pp)) /\ available_islands = {} &
    // Union of all player islands and available islands is equal to all islands
    UNION pp.(pp : dom(player_islands) | player_islands(pp)) \/ available_islands = ISLAND &
    // All islands have a happiness value between 0 and MAX_HAPPINESS 
    ran(island_happiness) <: 0..MAX_HAPPINESS

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
                island_happiness(i) := ISLAND_HAPPINESS_ACQUIRED
            END ||
            turn_completed := turn_completed \/ {p}
        END;
    
    InvestOnResources(p) =
        PRE
            p : players &
            p /: turn_completed &
            turn > 0
        THEN
            player_coins(p) := player_coins(p) + card(player_islands(p)) ||
            island_happiness := island_happiness <+ %i.(i : player_islands(p) | max({0, island_happiness(i) - HAPPINESS_FEE}))) ||
            available_islands := available_islands \/ { i | i : player_islands(p) & island_happiness(i) <= 0 } ||
            player_islands(p) := player_islands(p) - { i | i : player_islands(p) & island_happiness(i) <= 0 } ||
            turn_completed := turn_completed \/ {p}
        END;

    InvestOnHappiness(p) =
        PRE
            p : players &
            p /: turn_completed &
            player_coins(p) >= card(player_islands(p)) &
            turn > 0
        THEN
            player_coins(p) := player_coins(p) - card(player_islands(p)) ||
            island_happiness := island_happiness <+ %i.(i : player_islands(p) | island_happiness(i) + HAPPINESS_FEE);
            island_happiness := island_happiness <+ %i.(i : player_islands(p) & island_happiness(i) > MAX_HAPPINESS | MAX_HAPPINESS) ||
            turn_completed := turn_completed \/ {p}
        END;
    
    AttackPlayer(attacker, victim, dice_attacker, dice_victim) =
        PRE
            attacker : players &
            attacker /: turn_completed &
            victim : players &
            attacker /= victim &
            dice_attacker : 1..6 &
            dice_victim : 1..6 &
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
                        island_happiness(i) := ATTACK_SUCCESS_HAPPINESS
                    END
                ELSIF card(player_islands(attacker)) > card(player_islands(victim)) & attacker_happiness < victim_happiness THEN
                    ANY i WHERE i : player_islands(victim) THEN
                        player_islands(attacker) := player_islands(attacker) \/ {i};
                        player_islands(victim) := player_islands(victim) - {i};
                        island_happiness(i) := ATTACK_FAIL_HAPPINESS
                    END
                ELSE
                    IF dice_attacker > dice_victim THEN
                        ANY i WHERE i : player_islands(victim) THEN
                            player_islands(attacker) := player_islands(attacker) \/ {i};
                            player_islands(victim) := player_islands(victim) - {i};
                            island_happiness(i) := ISLAND_HAPPINESS_ACQUIRED
                        END
                    ELSE
                        ANY i WHERE i : player_islands(attacker) THEN
                            player_islands(victim) := player_islands(victim) \/ {i};
                            player_islands(attacker) := player_islands(attacker) - {i};
                            island_happiness(i) := ISLAND_HAPPINESS_ACQUIRED
                        END
                    END
                END;
                turn_completed := turn_completed \/ {attacker}
            END
        END;

    NextTurn =
        PRE
            card(turn_completed) = card(players) &
            turn > 0
        THEN
            turn := turn + 1 ||
            turn_completed := {} ||
            player_coins := player_coins <+ %p.(p : players | player_coins(p) + 1) ||
            players := { p | p : players & card(player_islands(p)) > 0}
        END;

    winner <-- EndGame =
        PRE
            card(players) = 1 &
            turn > 0
        THEN
            winner := players || turn := 0
        END
END