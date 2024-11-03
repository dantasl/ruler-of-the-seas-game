# Ruler of the Seas - Formal Specifications (2024.2/DIMAp)

![image](https://github.com/user-attachments/assets/ba762776-fdb5-4b2c-82f1-6a1d8ed2e14f)

### Ruler of the Seas is the simulation of a multiplayer table top game developed by Lucas Dantas for the Formal Specifications graduate class of 2024.2.

#### Here are the rules:

* The game requires a minimum of 2 players and supports up to a maximum of 4 players per match.
* The game is structured in turns, where each player has a set of actions that they can perform (and deal with its consequences) in order to accumulate resources, increase the happiness of their civilians and/or attack other players.
* The order in which every player plays their turn is not fixed, they'free to take initiative at different orders each turn.
* The game begins with every player controlling 1 island and the happiness level of their citizens at 100. Also, all players start with 2 coins.
* At the end of the each turn, every player receives 1 golden coin.
* At the start of each of their turns, players can choose one of the following actions: invest on resources, invest on happiness, acquire another empty island or attacking another player.
* Investing on resources makes the player receive 1 extra golden coin at that turn per island that they control, but decreases the happiness by 20 points on each of the islands that player controls.
* Investing on happiness makes the player pay 1 golden coin per each island they control, but it increases happiness levels by 20 points on each island.
* Attacking one player has a little bit more of nuance. It costs 4 golden coins. If the attacker has more islands and an overall bigger happiness level (the sum of all happiness levels of the islands the player controls), then they steal the island from their victim, acquiring it with a happiness level set to 80. If they have more islands but don't surpass their hapiness level, then they steal the island with a happiness level set to 20. Any other scenario will then require both players to roll a die. The player who scores the highest number on the die gets to keep all of their islands and steal one island from the opponent who scored lower, with the happiness level of that stolen island set to 50.
* A player automatically loses an island if the happiness level of their population reaches 0.
* A player automatically is removed from the game (loses) if they do not control any island.
* The game is over when there's only one player remaining.

#### Variables:
* Players;
* Islands of these players;
* Happiness level of each island controlled by the player (from 0 to 100);
* The turn counter;
* A control that indicates whether a player has already completed their turn or not.
