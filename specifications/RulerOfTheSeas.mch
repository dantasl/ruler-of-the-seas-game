MACHINE RulerOfTheSeas
SETS
    PLAYER = {p1, p2, p3, p4}   // Up to 4 players
    ISLAND
    PLAY_STYLE = {friendly, moderate, aggressive}

CONSTANTS
    MAX_PLAYERS, MIN_PLAYERS, MAX_HAPPINESS, INIT_HAPPINESS, 
    FRIENDLY_FACTOR, MODERATE_FACTOR, AGGRESSIVE_FACTOR

PROPERTIES
    MAX_PLAYERS = 4 &
    MIN_PLAYERS = 2 &
    MAX_HAPPINESS = 100 &
    INIT_HAPPINESS = 100 &
    FRIENDLY_FACTOR = 3 &
    MODERATE_FACTOR = 2 &
    AGGRESSIVE_FACTOR = 1

VARIABLES
    players, active_players, player_turn, player_coins, player_islands, 
    island_happiness, empty_islands, turn_completed, play_style

INVARIANTS
    players ⊆ PLAYER &
    active_players ⊆ players &
    player_coins ∈ players → NAT &
    player_islands ∈ players → POW(ISLAND) &
    island_happiness ∈ ISLAND → 0..MAX_HAPPINESS &
    empty_islands ⊆ ISLAND &
    turn_completed ⊆ players &
    player_turn ∈ 0..card(players)

INITIALISATION
    players := ∅ ||
    active_players := ∅ ||
    player_coins := ∅ ||
    player_islands := ∅ ||
    island_happiness := ∅ ||
    empty_islands := ∅ ||
    turn_completed := ∅ ||
    player_turn := 0

OPERATIONS
    AddPlayer(p) =
        PRE
            p ∈ PLAYER & card(players) < MAX_PLAYERS & p ∉ players
        THEN
            players := players ∪ {p} ||
            active_players := active_players ∪ {p} ||
            player_coins(p) := 0 ||
            player_islands(p) := ∅
        END;
        
    StartGame(style) =
        PRE
            style ∈ PLAY_STYLE & card(players) >= MIN_PLAYERS
        THEN
            play_style := style ||
            empty_islands := InitEmptyIslands(style) ||
            ANY p WHERE p ∈ players THEN
                player_islands(p) := {NewIsland(p)} ||
                island_happiness(NewIsland(p)) := INIT_HAPPINESS
            END
        END;
    
    Turn(p) =
        PRE
            p ∈ active_players & p ∉ turn_completed
        THEN
            player_coins(p) := player_coins(p) + 1 ||
            turn_completed := turn_completed ∪ {p}
        END;

    InvestOnResources(p) =
        PRE
            p ∈ players & p ∉ turn_completed
        THEN
            ANY i WHERE i ∈ player_islands(p) THEN
                player_coins(p) := player_coins(p) + 1 ||
                island_happiness(i) := island_happiness(i) - 20
            END
        END;

    InvestOnHappiness(p) =
        PRE
            p ∈ players & p ∉ turn_completed &
            player_coins(p) ≥ card(player_islands(p))
        THEN
            player_coins(p) := player_coins(p) - card(player_islands(p)) ||
            ANY i WHERE i ∈ player_islands(p) THEN
                island_happiness(i) := island_happiness(i) + 20
            END
        END;

    AcquireIsland(p) =
        PRE
            p ∈ players & p ∉ turn_completed & card(empty_islands) > 0 &
            player_coins(p) ≥ 3
        THEN
            player_coins(p) := player_coins(p) - 3 ||
            ANY i WHERE i ∈ empty_islands THEN
                player_islands(p) := player_islands(p) ∪ {i} ||
                empty_islands := empty_islands \ {i} ||
                HalfHappiness(p)
            END
        END;

    AttackPlayer(attacker, victim) =
        PRE
            attacker ∈ players & victim ∈ players &
            attacker ≠ victim & player_coins(attacker) ≥ 4
        THEN
            player_coins(attacker) := player_coins(attacker) - 4 ||
            IF CanStealIsland(attacker, victim) THEN
                StealIsland(attacker, victim)
            ELSE
                RollDice(attacker, victim)
            END
        END;

    NextTurn() =
        PRE
            turn_completed = players
        THEN
            player_turn := player_turn + 1 ||
            turn_completed := ∅
        END;

    RemovePlayer(p) =
        PRE
            p ∈ players & player_islands(p) = ∅
        THEN
            active_players := active_players \ {p}
        END;

    CheckGameOver() =
        PRE
            card(active_players) = 1
        THEN
            skip
        END;

    /* Helper Operations */

    InitEmptyIslands(style) =
        CASE
            style = friendly → 
                result := {i | i ∈ ISLAND & i ≤ FRIENDLY_FACTOR * card(players)}
            style = moderate → 
                result := {i | i ∈ ISLAND & i ≤ MODERATE_FACTOR * card(players)}
            style = aggressive → 
                result := {i | i ∈ ISLAND & i ≤ AGGRESSIVE_FACTOR * card(players)}
        END;

    NewIsland(p) = 
        ANY i WHERE i ∉ empty_islands & i ∉ ⋃(player_islands[players]) THEN 
            result := i 
        END;

    HalfHappiness(p) =
        ANY i WHERE i ∈ player_islands(p) THEN
            island_happiness(i) := island_happiness(i) / 2
        END;

    CanStealIsland(attacker, victim) =
        card(player_islands(attacker)) > card(player_islands(victim)) &
        SumHappiness(attacker) > SumHappiness(victim);

    StealIsland(attacker, victim) =
        ANY i WHERE i ∈ player_islands(victim) THEN
            player_islands(attacker) := player_islands(attacker) ∪ {i} ||
            player_islands(victim) := player_islands(victim) \ {i} ||
            island_happiness(i) := 80
        END;

    RollDice(p1, p2) =
        ANY d1, d2 WHERE d1 ∈ 1..6 & d2 ∈ 1..6 THEN
            IF d1 > d2 THEN StealIsland(p1, p2) ELSE skip END
        END;

    SumHappiness(p) = 
        result := Σ(i).(i ∈ player_islands(p) | island_happiness(i))

END
