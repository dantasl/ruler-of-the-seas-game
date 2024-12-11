#ifndef _RulerOfTheSeas_h
#define _RulerOfTheSeas_h

#include <stdint.h>
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#define RulerOfTheSeas__PLAYER__max 3
#define RulerOfTheSeas__ISLAND__max 11
/* Clause SETS */
typedef int RulerOfTheSeas__PLAYER;
typedef int RulerOfTheSeas__ISLAND;
typedef enum
{
    RulerOfTheSeas__CONFIGURING,
    RulerOfTheSeas__PLAYING,
    RulerOfTheSeas__FINISHED
    
} RulerOfTheSeas__GAME_STATE;
#define RulerOfTheSeas__GAME_STATE__max 3

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

extern void RulerOfTheSeas__INITIALISATION(void);

/* Clause OPERATIONS */

extern void RulerOfTheSeas__AddPlayer(RulerOfTheSeas__PLAYER pp);
extern void RulerOfTheSeas__StartGame(void);
extern void RulerOfTheSeas__AcquireIsland(RulerOfTheSeas__PLAYER pp);
extern void RulerOfTheSeas__InvestOnResources(RulerOfTheSeas__PLAYER pp);
extern void RulerOfTheSeas__InvestOnHappiness(RulerOfTheSeas__PLAYER pp);
extern void RulerOfTheSeas__AttackPlayer(RulerOfTheSeas__PLAYER attacker, RulerOfTheSeas__PLAYER victim, int32_t dice_attacker, int32_t dice_victim);
extern void RulerOfTheSeas__NextTurn(void);
extern void RulerOfTheSeas__StartNewGame(void);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _RulerOfTheSeas_h */
