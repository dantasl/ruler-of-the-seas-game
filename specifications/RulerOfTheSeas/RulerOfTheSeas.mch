MACHINE RulerOfTheSeas
    
SETS
    PLAYER; ISLAND; GAME_STATE = {CONFIGURING, PLAYING, FINISHED}

CONSTANTS
    MAX_PLAYERS,
    MIN_PLAYERS,
    MAX_HAPPINESS,
    HAPPINESS_FEE,
    MAX_ISLANDS,
    ISLAND_HAPPINESS_ACQUIRED,
    ATTACK_SUCCESS_HAPPINESS,
    ATTACK_FAIL_HAPPINESS

PROPERTIES
    PLAYER:FIN(PLAYER) &
    ISLAND:FIN(ISLAND) &
    MAX_PLAYERS : NAT1 &
    MIN_PLAYERS : NAT1 &
    MAX_HAPPINESS : NAT1 &
    HAPPINESS_FEE : NAT1 &
    ISLAND_HAPPINESS_ACQUIRED : NAT1 &
    ATTACK_SUCCESS_HAPPINESS : NAT1 &
    ATTACK_FAIL_HAPPINESS : NAT1 &
    MIN_PLAYERS <= MAX_PLAYERS &
    MAX_HAPPINESS > 0 &
    MAX_ISLANDS = 12 &
    card(ISLAND) = MAX_ISLANDS &
    MAX_PLAYERS = 4 & 
    MIN_PLAYERS = 2 &
    card(PLAYER) >= MIN_PLAYERS &
    card(GAME_STATE) = 3 &
    MAX_HAPPINESS = 100 &
    HAPPINESS_FEE = 20 &
    ISLAND_HAPPINESS_ACQUIRED = 50 &
    ATTACK_SUCCESS_HAPPINESS = 80 &
    ATTACK_FAIL_HAPPINESS = 20

VARIABLES
    players, player_coins, player_islands, available_islands,
    island_happiness, turn_completed, game_state, winner

INVARIANT
    players <: PLAYER &
    players:FIN(players) &
    card(players) <= MAX_PLAYERS &
    
    player_coins : players --> NAT &
    
    player_islands : players --> POW(ISLAND) &
    
    available_islands <: ISLAND &
    available_islands:FIN(available_islands) &
    
    island_happiness : ISLAND --> (0..MAX_HAPPINESS) &
    
    turn_completed <: players &
    game_state : GAME_STATE &
    winner <: players &
    card(winner) <= 1 &
    (game_state = FINISHED => (card(players) = 1 & winner = players)) &
    (game_state /= FINISHED => winner = {}) &
    
    !(p1, p2) . (p1 : players & p2 : players & p1 /= p2 => player_islands(p1) /\ player_islands(p2) = {}) & 
    UNION pp.(pp : dom(player_islands) | player_islands(pp)) /\ available_islands = {} &
    UNION pp.(pp : dom(player_islands) | player_islands(pp)) \/ available_islands = ISLAND &
    ran(island_happiness) <: 0..MAX_HAPPINESS

INITIALISATION
    players := {} ||
    player_coins := {} ||
    player_islands := {} ||
    available_islands := ISLAND ||
    island_happiness := ISLAND * {MAX_HAPPINESS} ||
    turn_completed := {} ||
    winner := {} ||
    game_state := CONFIGURING

OPERATIONS
    AddPlayer(pp) =
        PRE
            pp : PLAYER & card(players) < MAX_PLAYERS &
            pp /: players &
            game_state = CONFIGURING
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
            game_state = CONFIGURING
        THEN
            game_state := PLAYING
        END;
    
    AcquireIsland(pp) =
        PRE
            pp : PLAYER &
            pp /: turn_completed &
            card(available_islands) > 0 &
            player_coins(pp) >= 3 &
            game_state = PLAYING
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
            pp : PLAYER &
            pp /: turn_completed &
            game_state = PLAYING
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
            pp : PLAYER &
            pp /: turn_completed &
            player_coins(pp) >= card(player_islands(pp)) &
            game_state = PLAYING
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
            attacker : PLAYER &
            attacker /: turn_completed &
            victim : PLAYER &
            attacker /= victim &
            dice_attacker : 1..6 &
            dice_victim : 1..6 &
            player_coins(attacker) >= 4 &
            game_state = PLAYING
        THEN
            ANY attacker_happiness, victim_happiness
            WHERE attacker_happiness = SIGMA(ii).(ii : player_islands(attacker) | island_happiness(ii)) &
                  victim_happiness = SIGMA(ii).(ii : player_islands(victim) | island_happiness(ii))
            THEN
                player_coins(attacker) := player_coins(attacker) - 4 ||
                turn_completed := turn_completed \/ {attacker} ||
                ANY ii, jj 
                WHERE ii : player_islands(victim) & jj : player_islands(attacker)
                THEN
                    IF card(player_islands(attacker)) > card(player_islands(victim)) THEN
                        IF attacker_happiness > victim_happiness THEN
                            island_happiness(ii) := ATTACK_SUCCESS_HAPPINESS
                        ELSIF attacker_happiness < victim_happiness THEN
                            island_happiness(ii) := ATTACK_FAIL_HAPPINESS
                        END ||
                        player_islands := player_islands <+ { attacker |-> (player_islands(attacker) \/ {ii}), victim |-> (player_islands(victim) - {ii}) }
                    ELSE
                        IF dice_attacker > dice_victim THEN
                            island_happiness(ii) := ISLAND_HAPPINESS_ACQUIRED ||
                            player_islands := player_islands <+ { attacker |-> (player_islands(attacker) \/ {ii}), victim |-> (player_islands(victim) - {ii}) }
                        ELSE
                            island_happiness(jj) := ISLAND_HAPPINESS_ACQUIRED ||
                            player_islands := player_islands <+ { attacker |-> (player_islands(attacker) - {jj}), victim |-> (player_islands(victim) \/ {jj}) }
                        END
                    END
                END
            END
        END;

    NextTurn =
        PRE
            card(turn_completed) = card(players) &
            game_state = PLAYING
        THEN
            turn_completed := {} ||
            player_coins := player_coins <+ %pp.(pp : players | player_coins(pp) + 1) ||
            ANY ppp
            WHERE ppp = { pp | pp : players & card(player_islands(pp)) > 0}
            THEN
                players := ppp ||
                IF card(ppp) = 1 THEN
                    winner := ppp ||
                    game_state := FINISHED
                END
            END
        END;
    
    StartNewGame = 
        PRE
            game_state = FINISHED
        THEN
            players := {} ||
            player_coins := {} ||
            player_islands := {} ||
            available_islands := ISLAND ||
            island_happiness := ISLAND * {MAX_HAPPINESS} ||
            turn_completed := {} ||
            winner := {} ||
            game_state := CONFIGURING
        END;
    
    query_game_state <-- GetGameState =
        BEGIN
            query_game_state := game_state
        END;
    
    query_player_count <-- GetPlayersCount =
        BEGIN
            query_player_count := card(players)
        END;
    
    query_player_winner <-- CheckPlayerWinner(pp) =
        PRE
            pp : PLAYER
        THEN
            IF pp : winner THEN
                query_player_winner := TRUE
            ELSE
                query_player_winner := FALSE
            END
        END;
    
    query_player_turn_completed <-- CheckPlayerTurnCompleted(pp) =
        PRE
            pp : PLAYER
        THEN
            IF pp : turn_completed THEN
                query_player_turn_completed := TRUE
            ELSE
                query_player_turn_completed := FALSE
            END
        END;
    
    query_turn_completed_count <-- GetTurnCompletedCount =
        BEGIN
            query_turn_completed_count := card(turn_completed)
        END;
    
    query_player_is_active <-- CheckPlayerIsActive(pp) =
        PRE
            pp : PLAYER
        THEN
            IF pp : players THEN
                query_player_is_active := TRUE
            ELSE
                query_player_is_active := FALSE
            END
        END;

    query_player_coins <-- GetPlayerCoins(pp) =
        PRE
            pp : PLAYER
        THEN
            query_player_coins := player_coins(pp)
        END;
    
    query_player_has_island <-- CheckPlayerHasIsland(pp, ii) =
        PRE
            pp : PLAYER &
            ii : ISLAND
        THEN
            IF ii : player_islands(pp) THEN
                query_player_has_island := TRUE
            ELSE
                query_player_has_island := FALSE
            END
        END;
    
    query_player_islands_count <-- GetPlayerIslandsCount(pp) =
        PRE
            pp : PLAYER
        THEN
            query_player_islands_count := card(player_islands(pp))
        END;
    
    query_total_happiness_player <-- GetTotalHappinessPlayer(pp) =
        PRE
            pp : PLAYER
        THEN
            query_total_happiness_player := SIGMA(ii).(ii : player_islands(pp) | island_happiness(ii))
        END

END