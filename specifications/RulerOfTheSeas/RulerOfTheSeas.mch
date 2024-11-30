MACHINE RulerOfTheSeas
SEES RulerOfTheSeas_Context

VARIABLES
    players, player_coins, player_islands, available_islands,
    island_happiness, turn_completed, game_state, winner

INVARIANT
    players <: PLAYER &
    card(players) <= MAX_PLAYERS &
    player_coins : players --> NAT &
    player_islands : players --> POW(ISLAND) &
    available_islands <: ISLAND &
    island_happiness : ISLAND --> (0..MAX_HAPPINESS) &
    turn_completed <: players &
    game_state : GAME_STATE &
    winner <: PLAYER &
    card(winner) <= 1 &
    (game_state = FINISHED => (card(players) = 1 & winner = players)) &
    (game_state /= FINISHED => winner = {}) &
    // No player has the same island as another player
    !(p1, p2) . (p1 : players & p2 : players & p1 /= p2 => player_islands(p1) /\ player_islands(p2) = {}) & 
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
            pp : players &
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
            pp : players &
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
            pp : players &
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
            attacker : players &
            attacker /: turn_completed &
            victim : players &
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
            ANY pp
            WHERE pp = { pp | pp : players & card(player_islands(pp)) > 0}
            THEN
                players := pp ||
                IF card(pp) = 1 THEN
                    winner := pp ||
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
        END
    
    // Retorno não pode ser um conjunto (nenhum tipo abstrato)
    /*query_players <-- GetPlayers =
        BEGIN
            query_players := players
        END;
    
    query_player_coins <-- GetPlayerCoins(pp) =
        PRE
            pp : players
        THEN
            query_player_coins := player_coins(pp)
        END;
    
    // Retorno não pode ser um conjunto (nenhum tipo abstrato)
    query_player_islands <-- GetPlayerIslands(pp) =
        PRE
            pp : players
        THEN
            query_player_islands := player_islands(pp)
        END;
    
    query_island_happiness <-- GetIslandHappiness(ii) = 
        PRE
            ii : ISLAND
        THEN
            query_island_happiness := island_happiness(ii)
        END;
    
    // Retorno não pode ser um conjunto (nenhum tipo abstrato)
    query_available_islands <-- GetAvailableIslands = 
        BEGIN
            query_available_islands := available_islands
        END;
    
    query_game_state <-- GetGameState =
        BEGIN
            query_game_state := game_state
        END;
    
    // Retorno não pode ser um conjunto (nenhum tipo abstrato)
    query_turn_completed <-- GetTurnCompleted =
        BEGIN
            query_turn_completed := turn_completed
        END;
    
    query_winner <-- GetWinner =
        BEGIN
            query_winner := winner
        END;
    
    query_player_islands_happiness <-- GetPlayerIslandsHappiness(pp) =
        PRE
            pp : players
        THEN
            query_player_islands_happiness := SIGMA(ii).(ii : player_islands(pp) | island_happiness(ii))
        END*/
END