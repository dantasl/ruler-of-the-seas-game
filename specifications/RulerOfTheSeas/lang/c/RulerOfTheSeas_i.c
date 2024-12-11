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
/* Clause INITIALISATION */
void RulerOfTheSeas__INITIALISATION(void)
{
    
    unsigned int i = 0, j= 0;
    for(i = 0; i <= 3;i++)
    {
        RulerOfTheSeas__players_i[i] = false;
    }
    RulerOfTheSeas__player_count = 0;
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
    ;
}

void RulerOfTheSeas__AcquireIsland(RulerOfTheSeas__PLAYER pp)
{
    ;
}

void RulerOfTheSeas__InvestOnResources(RulerOfTheSeas__PLAYER pp)
{
    ;
}

void RulerOfTheSeas__InvestOnHappiness(RulerOfTheSeas__PLAYER pp)
{
    ;
}

void RulerOfTheSeas__AttackPlayer(RulerOfTheSeas__PLAYER attacker, RulerOfTheSeas__PLAYER victim, int32_t dice_attacker, int32_t dice_victim)
{
    ;
}

void RulerOfTheSeas__NextTurn(void)
{
    ;
}

void RulerOfTheSeas__StartNewGame(void)
{
    ;
}

