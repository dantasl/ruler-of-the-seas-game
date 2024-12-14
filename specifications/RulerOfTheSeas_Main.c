#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "lang/c/RulerOfTheSeas.h"

/* Forward declarations for helper functions */
static void print_game_state(void);
static void print_player_info(int player);
static bool all_players_added(void);
static void add_players_interactively(void);
static void player_turn(int player);
static void wait_for_enter(void);

int main(void)
{
    int choice;
    bool exit_game = false;

    while(!exit_game)
    {
        /* Initialize or re-initialize the game state */
        RulerOfTheSeas__INITIALISATION();

        printf("Welcome to Ruler Of The Seas!\n\n");
        add_players_interactively();

        /* Start the game */
        RulerOfTheSeas__StartGame();
        printf("Game started!\n");
        wait_for_enter();

        /* Main game loop */
        while(true)
        {
            /* Check game state */
            if (RulerOfTheSeas__game_state_i == RulerOfTheSeas__FINISHED)
            {
                printf("The game has finished!\n");
                /* Identify winner(s) */
                for (int p = 0; p < RulerOfTheSeas__MAX_PLAYERS; p++)
                {
                    if (RulerOfTheSeas__winner_i[p] == true) {
                        printf("Player %d is the winner!\n", p);
                    }
                }
                printf("1. Start a new game\n2. Exit\n");
                scanf("%d", &choice);
                if (choice == 1) {
                    RulerOfTheSeas__StartNewGame();
                    break; /* restart the outer loop */
                } else {
                    exit_game = true;
                    break;
                }
            }

            /* If the game is playing, each player takes a turn */
            if (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING)
            {
                /* Count how many players have played this turn. When it equals player_count, we call NextTurn */
                int turn_done = 0;
                /* We know how many players are currently in the game by RulerOfTheSeas__player_count */
                int current_player_count = RulerOfTheSeas__player_count;
                int played_this_turn = 0;

                /* Let's loop through all potential players and let them play if they are active */
                while (played_this_turn < current_player_count && RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING)
                {
                    /* Find a player that hasn't completed their turn */
                    for (int p = 0; p < RulerOfTheSeas__MAX_PLAYERS; p++)
                    {
                        if (RulerOfTheSeas__players_i[p] == true && RulerOfTheSeas__turn_completed_i[p] == false) {
                            /* This player's turn */
                            player_turn(p);
                            played_this_turn++;
                            break;
                        }
                    }
                }

                /* All active players have completed their turn, move to the next turn */
                if (RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING)
                {
                    RulerOfTheSeas__NextTurn();
                }
            }

            if (RulerOfTheSeas__game_state_i == RulerOfTheSeas__FINISHED)
                continue;
        }
    }

    printf("Thanks for playing!\n");
    return 0;
}

static void add_players_interactively(void)
{
    int num_players;
    printf("How many players do you want to add? (Between %d and %d): ", RulerOfTheSeas__MIN_PLAYERS, RulerOfTheSeas__MAX_PLAYERS);
    scanf("%d", &num_players);

    if (num_players < RulerOfTheSeas__MIN_PLAYERS || num_players > RulerOfTheSeas__MAX_PLAYERS)
    {
        printf("Invalid number of players. Setting to %d.\n", RulerOfTheSeas__MIN_PLAYERS);
        num_players = RulerOfTheSeas__MIN_PLAYERS;
    }

    for (int i = 0; i < num_players; i++)
    {
        RulerOfTheSeas__AddPlayer(i);
        printf("Player %d added.\n", i);
    }
    wait_for_enter();
}

static void player_turn(int player)
{
    int choice;
    bool turn_done = false;

    while(!turn_done && RulerOfTheSeas__game_state_i == RulerOfTheSeas__PLAYING)
    {
        print_player_info(player);
        printf("Player %d, choose an action:\n", player);
        printf("1. AcquireIsland\n");
        printf("2. InvestOnResources\n");
        printf("3. InvestOnHappiness\n");
        printf("4. AttackPlayer\n");
        printf("(Any other number to skip turn)\n");
        scanf("%d", &choice);

        switch(choice)
        {
            case 1: /* AcquireIsland */
                RulerOfTheSeas__AcquireIsland(player);
                if (RulerOfTheSeas__turn_completed_i[player] == true)
                    turn_done = true;
                else
                    printf("AcquireIsland action failed (preconditions not met).\n");
                break;

            case 2: /* InvestOnResources */
                RulerOfTheSeas__InvestOnResources(player);
                if (RulerOfTheSeas__turn_completed_i[player] == true)
                    turn_done = true;
                else
                    printf("InvestOnResources action failed (preconditions not met).\n");
                break;

            case 3: /* InvestOnHappiness */
                RulerOfTheSeas__InvestOnHappiness(player);
                if (RulerOfTheSeas__turn_completed_i[player] == true)
                    turn_done = true;
                else
                    printf("InvestOnHappiness action failed (preconditions not met).\n");
                break;

            case 4: /* AttackPlayer */
            {
                int victim, dice_attacker, dice_victim;
                printf("Enter victim player ID: ");
                scanf("%d", &victim);
                printf("Enter dice for attacker (1..6): ");
                scanf("%d", &dice_attacker);
                printf("Enter dice for victim (1..6): ");
                scanf("%d", &dice_victim);
                RulerOfTheSeas__AttackPlayer(player, victim, dice_attacker, dice_victim);
                if (RulerOfTheSeas__turn_completed_i[player] == true)
                    turn_done = true;
                else
                    printf("AttackPlayer action failed (preconditions not met).\n");
            }
            break;

            default:
                /* Skip turn (not defined in the spec, but we can simulate by just marking turn completed) */
                /* Actually, we can't just mark turn_completed because the B machine doesn't define that.
                 * So the player effectively "wastes" their turn by trying a no-op operation that doesn't set turn_completed.
                 * If we want a "skip turn" functionality, we'd need to define a new operation.
                 * For now, just break and let them choose again or let them exit by pressing enter.
                 */
                printf("No valid action chosen. Press enter to skip...\n");
                wait_for_enter();
                /* The machine doesn't have a skip turn operation.
                 * If you want to allow skipping, you'd need an operation or just let the player do nothing.
                 * For simplicity, let's just consider that if they don't pick a valid action, their turn ends without changes.
                 */
                RulerOfTheSeas__turn_completed_i[player] = true;
                RulerOfTheSeas__turn_completed_count = RulerOfTheSeas__turn_completed_count+1;
                turn_done = true;
                break;
        }
    }
}

static void print_player_info(int player)
{
    printf("\n--- Player %d Info ---\n", player);
    printf("Coins: %d\n", RulerOfTheSeas__player_coins_i[player]);
    printf("Islands owned: ");
    for (int i = 0; i < RulerOfTheSeas__MAX_ISLANDS; i++)
    {
        if (RulerOfTheSeas__player_islands_i[player][i] == true)
            printf("%d ", i);
    }
    printf("\n----------------------\n");
}

static void wait_for_enter(void)
{
    printf("Press Enter to continue...\n");
    getchar(); /* consume leftover newline if any */
    getchar(); /* wait for user to press enter */
}
