/* WARNING if type checker is not performed, translation could contain errors ! */

#include "RulerOfTheSeas.h"

/* Clause CONCRETE_CONSTANTS */
/* Basic constants */

#define RulerOfTheSeas__MAX_PLAYERS 4
#define RulerOfTheSeas__MIN_PLAYERS 2
#define RulerOfTheSeas__MAX_HAPPINESS 100
#define RulerOfTheSeas__HAPPINESS_FEE 20
#define RulerOfTheSeas__MAX_ISLANDS 12
#define RulerOfTheSeas__ISLAND_HAPPINESS_ACQUIRED 50
#define RulerOfTheSeas__ATTACK_SUCCESS_HAPPINESS 80
#define RulerOfTheSeas__ATTACK_FAIL_HAPPINESS 20
/* Array and record constants */
/* Clause CONCRETE_VARIABLES */

static bool RulerOfTheSeas__players_i[4];
static int32_t RulerOfTheSeas__player_coins_i[4];
static bool RulerOfTheSeas__player_islands_i[4][12];
static bool RulerOfTheSeas__available_islands_i[12];
static bool RulerOfTheSeas__turn_completed_i[4];
static RulerOfTheSeas__GAME_STATE RulerOfTheSeas__game_state_i;
static int32_t RulerOfTheSeas__island_happiness_i[12];
static bool RulerOfTheSeas__winner_i[4];
static int32_t RulerOfTheSeas__player_count;
static int32_t RulerOfTheSeas__available_islands_count;
static int32_t RulerOfTheSeas__turn_completed_count;
/* Clause INITIALISATION */
void RulerOfTheSeas__INITIALISATION(void)
{
    
    unsigned int i = 0, j= 0;
    for(i = 0; i <= 3;i++)
    {
        RulerOfTheSeas__players_i[i] = false;
    }
    RulerOfTheSeas__player_count = 0;
    RulerOfTheSeas__turn_completed_count = 0;
    for(i = 0; i <= 11;i++)
    {
        RulerOfTheSeas__island_happiness_i[i] = RulerOfTheSeas__MAX_HAPPINESS;
    }
    for(i = 0; i <= 3;i++)
    {
        RulerOfTheSeas__player_coins_i[i] = 0;
    }
    for(i = 0; i <= 11;i++)
    {
        RulerOfTheSeas__available_islands_i[i] = true;
    }
    RulerOfTheSeas__available_islands_count = RulerOfTheSeas__MAX_ISLANDS;
    for(i = 0; i <= 3;i++)
    {
        RulerOfTheSeas__turn_completed_i[i] = false;
    }
    for(i = 0; i <= 3;i++)
    {
        for(j = 0; j <= 11;j++)
        {
            RulerOfTheSeas__player_islands_i[i][j] = false;
        }
    }
    RulerOfTheSeas__game_state_i = RulerOfTheSeas__CONFIGURING;
    for(i = 0; i <= 3;i++)
    {
        RulerOfTheSeas__winner_i[i] = false;
    }
}

/* Clause OPERATIONS */

void RulerOfTheSeas__AddPlayer(RulerOfTheSeas__PLAYER pp)
{
    {
        bool is_player_in;
        
        is_player_in = RulerOfTheSeas__players_i[pp];
        if((((RulerOfTheSeas__player_count) < (RulerOfTheSeas__MAX_PLAYERS)) &&
            (is_player_in == false)) &&
        (RulerOfTheSeas__game_state_i == RulerOfTheSeas__CONFIGURING))
        {
            RulerOfTheSeas__players_i[pp] = true;
            RulerOfTheSeas__player_coins_i[pp] = 2;
            RulerOfTheSeas__player_count = RulerOfTheSeas__player_count+1;
            {
                int32_t ii_index;
                bool found;
                
                ii_index = 0;
                found = false;
                while(((ii_index) <= (RulerOfTheSeas__MAX_ISLANDS)) &&
                (found == false))
                {
                    {
                        bool is_available_island;
                        
                        is_available_island = RulerOfTheSeas__available_islands_i[ii_index];
                        if(is_available_island == true)
                        {
                            RulerOfTheSeas__player_islands_i[pp][ii_index] = true;
                            RulerOfTheSeas__available_islands_i[ii_index] = false;
                            found = true;
                        }
                        else
                        {
                            ii_index = ii_index+1;
                        }
                    }
                }
            }
        }
    }
}

void RulerOfTheSeas__StartGame(void)
{
    if((((RulerOfTheSeas__player_count) >= (RulerOfTheSeas__MIN_PLAYERS)) &&
        ((RulerOfTheSeas__player_count) <= (RulerOfTheSeas__MAX_PLAYERS))) &&
    (RulerOfTheSeas__game_state_i == RulerOfTheSeas__CONFIGURING))
    {
        RulerOfTheSeas__game_state_i = RulerOfTheSeas__PLAYING;
    }
}

void RulerOfTheSeas__AcquireIsland(RulerOfTheSeas__PLAYER pp)
{
    {
        bool player_turn_not_completed;
        int32_t player_current_coins;
        
        player_turn_not_completed = RulerOfTheSeas__turn_completed_i[pp];
        player_current_coins = RulerOfTheSeas__player_coins_i[pp];
        if((((player_turn_not_completed == false) &&
                ((RulerOfTheSeas__available_islands_count) > (0))) &&
            ((player_current_coins) >= (3))) &&
        (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING))
        {
            RulerOfTheSeas__player_coins_i[pp] = RulerOfTheSeas__player_coins_i[pp]-3;
            {
                int32_t ii_index;
                bool found;
                
                ii_index = 0;
                found = false;
                while(((ii_index) <= (RulerOfTheSeas__MAX_ISLANDS)) &&
                (found == false))
                {
                    {
                        bool is_available_island;
                        
                        is_available_island = RulerOfTheSeas__available_islands_i[ii_index];
                        if(is_available_island == true)
                        {
                            RulerOfTheSeas__player_islands_i[pp][ii_index] = true;
                            RulerOfTheSeas__available_islands_i[ii_index] = false;
                            RulerOfTheSeas__island_happiness_i[ii_index] = RulerOfTheSeas__ISLAND_HAPPINESS_ACQUIRED;
                            found = true;
                        }
                        else
                        {
                            ii_index = ii_index+1;
                        }
                    }
                }
            }
            RulerOfTheSeas__turn_completed_i[pp] = true;
            RulerOfTheSeas__turn_completed_count = RulerOfTheSeas__turn_completed_count+1;
        }
    }
}

void RulerOfTheSeas__InvestOnResources(RulerOfTheSeas__PLAYER pp)
{
    {
        bool player_turn_not_completed;
        
        player_turn_not_completed = RulerOfTheSeas__turn_completed_i[pp];
        if((player_turn_not_completed == false) &&
        (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING))
        {
            {
                int32_t ii;
                
                ii = 0;
                while((ii) < (RulerOfTheSeas__MAX_ISLANDS))
                {
                    {
                        bool is_player_island;
                        
                        is_player_island = RulerOfTheSeas__player_islands_i[pp][ii];
                        if(is_player_island == true)
                        {
                            RulerOfTheSeas__player_coins_i[pp] = RulerOfTheSeas__player_coins_i[pp]+1;
                            {
                                int32_t island_happiness_value;
                                int32_t happiness_minus_fee;
                                
                                island_happiness_value = RulerOfTheSeas__island_happiness_i[ii];
                                happiness_minus_fee = island_happiness_value-RulerOfTheSeas__HAPPINESS_FEE;
                                if((happiness_minus_fee) <= (0))
                                {
                                    RulerOfTheSeas__player_islands_i[pp][ii] = false;
                                    RulerOfTheSeas__available_islands_i[ii] = true;
                                }
                                else
                                {
                                    RulerOfTheSeas__island_happiness_i[ii] = happiness_minus_fee;
                                }
                            }
                        }
                        ii = ii+1;
                    }
                }
            }
            RulerOfTheSeas__turn_completed_i[pp] = true;
            RulerOfTheSeas__turn_completed_count = RulerOfTheSeas__turn_completed_count+1;
        }
    }
}

void RulerOfTheSeas__InvestOnHappiness(RulerOfTheSeas__PLAYER pp)
{
    {
        bool player_turn_not_completed;
        int32_t pi_counter;
        int32_t p_coins;
        int32_t ii;
        
        player_turn_not_completed = RulerOfTheSeas__turn_completed_i[pp];
        p_coins = RulerOfTheSeas__player_coins_i[pp];
        ii = 0;
        pi_counter = 0;
        while((ii) < (RulerOfTheSeas__MAX_ISLANDS))
        {
            {
                bool is_player_island;
                
                is_player_island = RulerOfTheSeas__player_islands_i[pp][ii];
                if(is_player_island == true)
                {
                    pi_counter = pi_counter+1;
                }
                ii = ii+1;
            }
        }
        if(((player_turn_not_completed == false) &&
            (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING)) &&
        ((p_coins) >= (pi_counter)))
        {
            {
                int32_t iii;
                
                iii = 0;
                while((iii) < (RulerOfTheSeas__MAX_ISLANDS))
                {
                    {
                        bool is_player_island;
                        
                        is_player_island = RulerOfTheSeas__player_islands_i[pp][iii];
                        if(is_player_island == true)
                        {
                            RulerOfTheSeas__player_coins_i[pp] = RulerOfTheSeas__player_coins_i[pp]+1;
                            {
                                int32_t island_happiness_value;
                                int32_t happiness_plus_fee;
                                
                                island_happiness_value = RulerOfTheSeas__island_happiness_i[iii];
                                happiness_plus_fee = island_happiness_value+RulerOfTheSeas__HAPPINESS_FEE;
                                if((happiness_plus_fee) > (100))
                                {
                                    RulerOfTheSeas__island_happiness_i[iii] = RulerOfTheSeas__MAX_HAPPINESS;
                                }
                                else
                                {
                                    RulerOfTheSeas__island_happiness_i[iii] = happiness_plus_fee;
                                }
                            }
                        }
                        iii = iii+1;
                    }
                }
            }
            RulerOfTheSeas__turn_completed_i[pp] = true;
            RulerOfTheSeas__turn_completed_count = RulerOfTheSeas__turn_completed_count+1;
        }
    }
}

void RulerOfTheSeas__AttackPlayer(RulerOfTheSeas__PLAYER attacker, RulerOfTheSeas__PLAYER victim, int32_t dice_attacker, int32_t dice_victim)
{
    {
        int32_t attacker_happiness;
        int32_t victim_happiness;
        int32_t attacker_coins;
        int32_t attacker_islands_count;
        int32_t victim_islands_count;
        int32_t last_found_island_attacker;
        int32_t last_found_island_victim;
        
        attacker_happiness = 0;
        victim_happiness = 0;
        attacker_coins = RulerOfTheSeas__player_coins_i[attacker];
        attacker_islands_count = 0;
        victim_islands_count = 0;
        last_found_island_attacker = -1;
        last_found_island_victim = -1;
        if((((attacker) != (victim)) &&
            ((attacker_coins) >= (4))) &&
        (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING))
        {
            RulerOfTheSeas__player_coins_i[attacker] = attacker_coins-4;
            {
                int32_t island_index;
                
                island_index = 0;
                while((island_index) < (RulerOfTheSeas__MAX_ISLANDS))
                {
                    {
                        bool is_attacker_island;
                        bool is_victim_island;
                        
                        is_attacker_island = RulerOfTheSeas__player_islands_i[attacker][island_index];
                        is_victim_island = RulerOfTheSeas__player_islands_i[victim][island_index];
                        if(is_attacker_island == true)
                        {
                            attacker_happiness = attacker_happiness+RulerOfTheSeas__island_happiness_i[island_index];
                            attacker_islands_count = attacker_islands_count+1;
                            last_found_island_attacker = island_index;
                        }
                        else if(is_victim_island == true)
                        {
                            victim_happiness = victim_happiness+RulerOfTheSeas__island_happiness_i[island_index];
                            victim_islands_count = victim_islands_count+1;
                            last_found_island_victim = island_index;
                        }
                        island_index = island_index+1;
                    }
                }
                if((attacker_islands_count) > (victim_islands_count))
                {
                    if((attacker_happiness) <= (victim_happiness))
                    {
                        if((last_found_island_victim) != (-1))
                        {
                            RulerOfTheSeas__island_happiness_i[last_found_island_victim] = RulerOfTheSeas__ATTACK_FAIL_HAPPINESS;
                        }
                    }
                    else
                    {
                        if((last_found_island_attacker) != (-1))
                        {
                            RulerOfTheSeas__island_happiness_i[last_found_island_attacker] = RulerOfTheSeas__ATTACK_SUCCESS_HAPPINESS;
                        }
                    }
                    if((last_found_island_victim) != (-1))
                    {
                        RulerOfTheSeas__player_islands_i[victim][last_found_island_victim] = false;
                        RulerOfTheSeas__player_islands_i[attacker][last_found_island_victim] = true;
                    }
                }
                else
                {
                    if((dice_attacker) > (dice_victim))
                    {
                        if((last_found_island_victim) != (-1))
                        {
                            RulerOfTheSeas__island_happiness_i[last_found_island_victim] = RulerOfTheSeas__ISLAND_HAPPINESS_ACQUIRED;
                            RulerOfTheSeas__player_islands_i[attacker][last_found_island_victim] = true;
                            RulerOfTheSeas__player_islands_i[victim][last_found_island_victim] = false;
                        }
                    }
                    else
                    {
                        if((last_found_island_attacker) != (-1))
                        {
                            RulerOfTheSeas__island_happiness_i[last_found_island_attacker] = RulerOfTheSeas__ISLAND_HAPPINESS_ACQUIRED;
                            RulerOfTheSeas__player_islands_i[attacker][last_found_island_attacker] = false;
                            RulerOfTheSeas__player_islands_i[victim][last_found_island_attacker] = true;
                        }
                    }
                }
            }
        }
    }
}

void RulerOfTheSeas__NextTurn(void)
{
    if((RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING) &&
    (RulerOfTheSeas__player_count == RulerOfTheSeas__turn_completed_count))
    {
        {
            int32_t pp;
            
            pp = 0;
            while((pp) < (RulerOfTheSeas__MAX_PLAYERS))
            {
                {
                    int32_t ii;
                    int32_t player_island_counter;
                    
                    ii = 0;
                    player_island_counter = 0;
                    while((ii) < (RulerOfTheSeas__MAX_ISLANDS))
                    {
                        {
                            bool is_player_island;
                            
                            is_player_island = RulerOfTheSeas__player_islands_i[pp][ii];
                            if(is_player_island == true)
                            {
                                {
                                    int32_t island_happiness_value;
                                    
                                    island_happiness_value = RulerOfTheSeas__island_happiness_i[ii];
                                    if((island_happiness_value) <= (0))
                                    {
                                        RulerOfTheSeas__player_islands_i[pp][ii] = false;
                                        RulerOfTheSeas__available_islands_i[ii] = true;
                                    }
                                    else
                                    {
                                        player_island_counter = player_island_counter+1;
                                    }
                                }
                            }
                            ii = ii+1;
                        }
                    }
                    if(player_island_counter == 0)
                    {
                        RulerOfTheSeas__players_i[pp] = false;
                        RulerOfTheSeas__player_count = RulerOfTheSeas__player_count-1;
                    }
                    if((RulerOfTheSeas__player_count == 1) &&
                    ((player_island_counter) > (0)))
                    {
                        RulerOfTheSeas__winner_i[pp] = true;
                        RulerOfTheSeas__game_state_i = RulerOfTheSeas__FINISHED;
                    }
                    pp = pp+1;
                }
            }
        }
    }
}

void RulerOfTheSeas__StartNewGame(void)
{
    unsigned int i = 0, j= 0;
    {
        if(RulerOfTheSeas__game_state_i == RulerOfTheSeas__FINISHED)
        {
            for(i = 0; i <= 3;i++)
            {
                RulerOfTheSeas__players_i[i] = false;
            }
            RulerOfTheSeas__player_count = 0;
            RulerOfTheSeas__turn_completed_count = 0;
            for(i = 0; i <= 11;i++)
            {
                RulerOfTheSeas__island_happiness_i[i] = RulerOfTheSeas__MAX_HAPPINESS;
            }
            for(i = 0; i <= 3;i++)
            {
                RulerOfTheSeas__player_coins_i[i] = 0;
            }
            for(i = 0; i <= 11;i++)
            {
                RulerOfTheSeas__available_islands_i[i] = true;
            }
            RulerOfTheSeas__available_islands_count = RulerOfTheSeas__MAX_ISLANDS;
            for(i = 0; i <= 3;i++)
            {
                RulerOfTheSeas__turn_completed_i[i] = false;
            }
            for(i = 0; i <= 3;i++)
            {
                for(j = 0; j <= 11;j++)
                {
                    RulerOfTheSeas__player_islands_i[i][j] = false;
                }
            }
            RulerOfTheSeas__game_state_i = RulerOfTheSeas__CONFIGURING;
            for(i = 0; i <= 3;i++)
            {
                RulerOfTheSeas__winner_i[i] = false;
            }
        }
    }
}

void RulerOfTheSeas__GetGameState(RulerOfTheSeas__GAME_STATE *query_game_state)
{
    (*query_game_state) = RulerOfTheSeas__game_state_i;
}

void RulerOfTheSeas__GetPlayersCount(int32_t *query_player_count)
{
    (*query_player_count) = RulerOfTheSeas__player_count;
}

void RulerOfTheSeas__CheckPlayerWinner(RulerOfTheSeas__PLAYER pp, bool *query_player_winner)
{
    {
        bool is_winner;
        
        is_winner = RulerOfTheSeas__winner_i[pp];
        if((RulerOfTheSeas__game_state_i == RulerOfTheSeas__FINISHED) &&
        (is_winner == true))
        {
            (*query_player_winner) = true;
        }
        else
        {
            (*query_player_winner) = false;
        }
    }
}

void RulerOfTheSeas__CheckPlayerTurnCompleted(RulerOfTheSeas__PLAYER pp, bool *query_player_turn_completed)
{
    {
        bool is_turn_completed;
        
        is_turn_completed = RulerOfTheSeas__turn_completed_i[pp];
        if((is_turn_completed == true) &&
        (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING))
        {
            (*query_player_turn_completed) = true;
        }
        else
        {
            (*query_player_turn_completed) = false;
        }
    }
}

void RulerOfTheSeas__GetTurnCompletedCount(int32_t *query_turn_completed_count)
{
    (*query_turn_completed_count) = RulerOfTheSeas__turn_completed_count;
}

void RulerOfTheSeas__CheckPlayerIsActive(RulerOfTheSeas__PLAYER pp, bool *query_player_is_active)
{
    {
        bool is_player_active;
        
        is_player_active = RulerOfTheSeas__players_i[pp];
        if((is_player_active == true) &&
        (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING))
        {
            (*query_player_is_active) = true;
        }
        else
        {
            (*query_player_is_active) = false;
        }
    }
}

void RulerOfTheSeas__GetPlayerCoins(RulerOfTheSeas__PLAYER pp, int32_t *query_player_coins)
{
    (*query_player_coins) = RulerOfTheSeas__player_coins_i[pp];
}

void RulerOfTheSeas__CheckPlayerHasIsland(RulerOfTheSeas__PLAYER pp, RulerOfTheSeas__ISLAND ii, bool *query_player_has_island)
{
    {
        bool is_player_island;
        
        is_player_island = RulerOfTheSeas__player_islands_i[pp][ii];
        if(is_player_island == true)
        {
            (*query_player_has_island) = true;
        }
        else
        {
            (*query_player_has_island) = false;
        }
    }
}

