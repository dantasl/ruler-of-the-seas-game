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
    AddPlayer(pp) =
        PRE
            pp : PLAYER & card(players) < MAX_PLAYERS &
            pp /: players &
            turn = 0
        THEN
            players := players \/ {pp} ||
            player_coins(pp) := 2 ||
            ANY ii WHERE ii : available_islands THEN
                player_islands(pp) := {ii} ||
                available_islands := available_islands - {ii}
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
    
    AcquireIsland(pp) =
        PRE
            pp : players &
            pp /: turn_completed &
            card(available_islands) > 0 &
            turn > 0 &
            player_coins(pp) >= 3
        THEN
            player_coins(pp) := player_coins(pp) - 3 ||
            ANY ii WHERE ii : available_islands THEN
                player_islands(pp) := player_islands(pp) \/ {ii} ||
                available_islands := available_islands - {ii} ||
                island_happiness(ii) := ISLAND_HAPPINESS_ACQUIRED
            END ||
            turn_completed := turn_completed \/ {pp}
        END;
    
    InvestOnResources(pp) =
        PRE
            pp : players &
            pp /: turn_completed &
            turn > 0
        THEN
            ANY ih
            WHERE ih = island_happiness <+ %ii.(ii : player_islands(pp) | max({0, island_happiness(ii) - HAPPINESS_FEE}))
            THEN
                player_coins(pp) := player_coins(pp) + card(player_islands(pp)) ||
                island_happiness := ih ||
                available_islands := available_islands \/ { ii | ii : player_islands(pp) & ih(ii) <= 0 } ||
                player_islands(pp) := player_islands(pp) - { ii | ii : player_islands(pp) & ih(ii) <= 0 } ||
                turn_completed := turn_completed \/ {pp}
            END
        END;

    InvestOnHappiness(pp) =
        PRE
            pp : players &
            pp /: turn_completed &
            player_coins(pp) >= card(player_islands(pp)) &
            turn > 0
        THEN
            ANY ih
            WHERE ih = island_happiness <+ %ii.(ii : player_islands(pp) | min({100, island_happiness(ii) + HAPPINESS_FEE}))
            THEN
                player_coins(pp) := player_coins(pp) - card(player_islands(pp)) ||
                island_happiness := ih ||
                turn_completed := turn_completed \/ {pp}
            END
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
                player_coins(attacker) := player_coins(attacker) - 4 ||
                attacker_happiness := SIGMA(ii).(ii : player_islands(attacker) | island_happiness(ii)) ||
                victim_happiness := SIGMA(ii).(ii : player_islands(victim) | island_happiness(ii)) ||
                IF card(player_islands(attacker)) > card(player_islands(victim)) & attacker_happiness > victim_happiness THEN
                    ANY ii WHERE ii : player_islands(victim) THEN
                        player_islands(attacker) := player_islands(attacker) \/ {ii} ||
                        player_islands(victim) := player_islands(victim) - {ii} ||
                        island_happiness(ii) := ATTACK_SUCCESS_HAPPINESS
                    END
                ELSIF card(player_islands(attacker)) > card(player_islands(victim)) & attacker_happiness < victim_happiness THEN
                    ANY ii WHERE ii : player_islands(victim) THEN
                        player_islands(attacker) := player_islands(attacker) \/ {ii} ||
                        player_islands(victim) := player_islands(victim) - {ii} ||
                        island_happiness(ii) := ATTACK_FAIL_HAPPINESS
                    END
                ELSE
                    IF dice_attacker > dice_victim THEN
                        ANY ii WHERE ii : player_islands(victim) THEN
                            player_islands(attacker) := player_islands(attacker) \/ {ii} ||
                            player_islands(victim) := player_islands(victim) - {ii} ||
                            island_happiness(ii) := ISLAND_HAPPINESS_ACQUIRED
                        END
                    ELSE
                        ANY ii WHERE ii : player_islands(attacker) THEN
                            player_islands(victim) := player_islands(victim) \/ {ii} ||
                            player_islands(attacker) := player_islands(attacker) - {ii} ||
                            island_happiness(ii) := ISLAND_HAPPINESS_ACQUIRED
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
            player_coins := player_coins <+ %pp.(pp : players | player_coins(pp) + 1) ||
            players := { pp | pp : players & card(player_islands(pp)) > 0}
        END;

    winner <-- EndGame =
        PRE
            card(players) = 1 &
            turn > 0
        THEN
            winner := players || turn := 0
        END
END