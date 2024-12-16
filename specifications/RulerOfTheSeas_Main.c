#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include "lang/c/RulerOfTheSeas.h"

static void print_game_state(void);
static void print_player_status(int player);
static bool any_active_players(void);
static int choose_active_player(void);
static void player_action_menu(int player);
static void print_actions_menu(void);
static void handle_acquire_island(int player);
static void handle_invest_resources(int player);
static void handle_invest_happiness(int player);
static void handle_attack_player(int player);
static void end_turn_phase(void);
static int roll_dice(void);

int main(void)
{
    // Initialize random seed for dice rolls
    srand((unsigned int)time(NULL));
    
    RulerOfTheSeas__INITIALISATION();

    RulerOfTheSeas__GAME_STATE game_state;
    RulerOfTheSeas__GetGameState(&game_state);

    printf("=== Ruler of the Seas ===\n");
    printf("Welcome! Let's configure the game.\n");

    // Configuration phase: add players
    while (game_state == RulerOfTheSeas__CONFIGURING)
    {
        int choice;
        printf("\nConfiguration Menu:\n");
        printf("1) Add Player\n");
        printf("2) Start Game\n");
        printf("Choice: ");
        scanf("%d", &choice);

        if (choice == 1)
        {
            int pc;
            RulerOfTheSeas__GetPlayersCount(&pc);
            if (pc >= 4)
            {
                printf("Maximum number of players reached!\n");
            }
            else
            {
                int new_player_id = pc; 
                printf("Adding player with ID: %d\n", new_player_id);
                RulerOfTheSeas__AddPlayer(new_player_id);
            }
        }
        else if (choice == 2)
        {
            int pc;
            RulerOfTheSeas__GetPlayersCount(&pc);
            if (pc < 2)
            {
                printf("Need at least 2 players to start.\n");
            }
            else
            {
                RulerOfTheSeas__StartGame();
                RulerOfTheSeas__GetGameState(&game_state);
                if (game_state == RulerOfTheSeas__PLAYING)
                {
                    printf("Game started!\n");
                }
                else
                {
                    printf("Could not start the game. Check conditions.\n");
                }
            }
        }
        else
        {
            printf("Invalid choice.\n");
        }

        RulerOfTheSeas__GetGameState(&game_state);
    }

    // Main game loop
    while (true)
    {
        RulerOfTheSeas__GetGameState(&game_state);
        if (game_state == RulerOfTheSeas__FINISHED)
        {
            printf("Game finished!\n");
            // Find the winner
            int pc;
            RulerOfTheSeas__GetPlayersCount(&pc);
            for (int p = 0; p < 4; p++)
            {
                bool is_winner;
                RulerOfTheSeas__CheckPlayerWinner(p, &is_winner);
                if (is_winner)
                {
                    printf("Player %d is the winner!\n", p);
                }
            }
            break;
        }
        else if (game_state == RulerOfTheSeas__PLAYING)
        {
            // During a turn, players perform actions in any order (only 1 action per player)
            int turn_completed_count;
            int players_count;
            RulerOfTheSeas__GetTurnCompletedCount(&turn_completed_count);
            RulerOfTheSeas__GetPlayersCount(&players_count);

            if (turn_completed_count == players_count)
            {
                RulerOfTheSeas__NextTurn();
                continue;
            }

            // Let the user choose which player will act now
            int active_player = choose_active_player();
            if (active_player < 0)
            {
                // No active player available (should not happen if game_state = PLAYING and turn not complete)
                continue;
            }

            bool turn_completed;
            RulerOfTheSeas__CheckPlayerTurnCompleted(active_player, &turn_completed);
            if (turn_completed)
            {
                printf("This player's turn is already completed this round.\n");
                continue; 
            }

            // Let the player choose an action
            player_action_menu(active_player);
        }
        else
        {
            // Should not happen, but just in case
            printf("Game is not in a recognized state.\n");
            break;
        }
    }

    return 0;
}

static void print_game_state(void)
{
    RulerOfTheSeas__GAME_STATE gs;
    RulerOfTheSeas__GetGameState(&gs);
    printf("Game State: ");
    if (gs == RulerOfTheSeas__CONFIGURING) printf("CONFIGURING\n");
    else if (gs == RulerOfTheSeas__PLAYING) printf("PLAYING\n");
    else if (gs == RulerOfTheSeas__FINISHED) printf("FINISHED\n");
}

static void print_player_status(int player)
{
    bool is_active;
    RulerOfTheSeas__CheckPlayerIsActive(player, &is_active);
    int coins;
    RulerOfTheSeas__GetPlayerCoins(player, &coins);

    printf("Player %d: %s, Coins: %d, Islands: ", player, is_active ? "Active" : "Inactive", coins);
    bool has_island = false;
    for (int i = 0; i < RulerOfTheSeas__MAX_ISLANDS; i++)
    {
        bool player_has_island;
        RulerOfTheSeas__CheckPlayerHasIsland(player, i, &player_has_island);
        if (player_has_island)
        {
            printf("%d ", i);
            has_island = true;
        }
    }
    if (!has_island) printf("None");
    printf("\n");
}

static bool any_active_players(void)
{
    for (int p = 0; p < 4; p++)
    {
        bool is_active;
        RulerOfTheSeas__CheckPlayerIsActive(p, &is_active);
        if (is_active) return true;
    }
    return false;
}

static int choose_active_player(void)
{
    // Print all players and let user choose one who hasn't completed turn
    int players_count;
    RulerOfTheSeas__GetPlayersCount(&players_count);
    if (players_count == 0) return -1; 

    printf("\nChoose a player to take action this turn:\n");
    for (int p = 0; p < 4; p++)
    {
        bool is_active;
        RulerOfTheSeas__CheckPlayerIsActive(p, &is_active);

        if (is_active)
        {
            bool turn_completed;
            RulerOfTheSeas__CheckPlayerTurnCompleted(p, &turn_completed);
            if (!turn_completed)
            {
                print_player_status(p);
            }
        }
    }

    int chosen;
    printf("Player ID: ");
    scanf("%d", &chosen);

    bool is_active;
    RulerOfTheSeas__CheckPlayerIsActive(chosen, &is_active);
    if (!is_active)
    {
        printf("This player is not active.\n");
        return -1;
    }

    bool turn_completed;
    RulerOfTheSeas__CheckPlayerTurnCompleted(chosen, &turn_completed);
    if (turn_completed)
    {
        printf("This player's turn is already completed.\n");
        return -1;
    }

    return chosen;
}

static void player_action_menu(int player)
{
    print_player_status(player);
    print_actions_menu();

    int action;
    printf("Choose action (1-4): ");
    scanf("%d", &action);

    switch (action)
    {
        case 1:
            handle_invest_resources(player);
            break;
        case 2:
            handle_invest_happiness(player);
            break;
        case 3:
            handle_acquire_island(player);
            break;
        case 4:
            handle_attack_player(player);
            break;
        default:
            printf("Invalid action.\n");
            break;
    }
}

static void print_actions_menu(void)
{
    printf("Available actions:\n");
    printf("1) Invest on Resources (Gain coins, lose happiness)\n");
    printf("2) Invest on Happiness (Spend coins, gain happiness)\n");
    printf("3) Acquire another Island (Cost 3 coins, get a new island)\n");
    printf("4) Attack another Player (Cost 4 coins, may steal island)\n");
}

static void handle_acquire_island(int player)
{
    RulerOfTheSeas__AcquireIsland(player);
    // If successful, turn_completed should be true
    bool turn_completed;
    RulerOfTheSeas__CheckPlayerTurnCompleted(player, &turn_completed);
    if (turn_completed)
    {
        printf("Island acquired successfully.\n");
    }
    else
    {
        printf("Could not acquire island. Check if you have enough coins or if islands are available.\n");
    }
}

static void handle_invest_resources(int player)
{
    RulerOfTheSeas__InvestOnResources(player);
    bool turn_completed;
    RulerOfTheSeas__CheckPlayerTurnCompleted(player, &turn_completed);
    if (turn_completed)
    {
        printf("Invested in resources successfully. You gained coins from each island but each island lost happiness.\n");
    }
    else
    {
        printf("Could not invest on resources. Maybe your turn is already done or game is not in playing state.\n");
    }
}

static void handle_invest_happiness(int player)
{
    RulerOfTheSeas__InvestOnHappiness(player);
    bool turn_completed;
    RulerOfTheSeas__CheckPlayerTurnCompleted(player, &turn_completed);
    if (turn_completed)
    {
        printf("Invested in happiness successfully. Islands gained happiness points.\n");
    }
    else
    {
        printf("Could not invest on happiness. Check if you have enough coins.\n");
    }
}

static void handle_attack_player(int player)
{
    printf("Choose a victim player ID to attack: ");
    int victim;
    scanf("%d", &victim);
    if (victim == player)
    {
        printf("You can't attack yourself!\n");
        return;
    }

    int dice_attacker = roll_dice();
    int dice_victim = roll_dice();
    printf("Attacker rolled %d, Victim rolled %d\n", dice_attacker, dice_victim);

    RulerOfTheSeas__AttackPlayer(player, victim, dice_attacker, dice_victim);

    bool turn_completed;
    RulerOfTheSeas__CheckPlayerTurnCompleted(player, &turn_completed);
    
    printf("Attack performed.\n");
}

static void end_turn_phase(void)
{
    RulerOfTheSeas__NextTurn();
}

static int roll_dice(void)
{
    return (rand() % 6) + 1; 
}