# Ruler of the Seas - Formal Specifications (2024.2/DIMAp)

![image](https://github.com/user-attachments/assets/fe5f979a-c546-4a46-9f38-6adb8dccd1f4)

Ruler of the Seas is the simulation of a multiplayer table top game developed by Lucas Dantas for the Formal Specifications graduate class of 2024.2.

Here are the rules:

* The game requires a minimum of 2 players and supports up to a maximum of 4 players per match.
* The game is structured in turns, where each player has a set of actions that they can perform (and deal with its consequences) in order to accumulate resources, increase the happiness of their civilians and/or attack other players.
* The order in which every player plays their turn is not fixed, they'free to take initiative at different orders each turn.
* The game begins with every player controlling 1 island and the happiness level of their citizens at 100.
* The players need to decide the play style of the match. The options are: friendly, moderate and aggressive. This choice impacts the amount of empty islands available for the players.
* At the start of each of their turns, every player receives 1 golden coin.
* Then, they can choose one of the following actions: invest on resources, invest on happiness, acquire another empty island or attack one player.
* Investing on resources makes the player receive 1 extra golden coin at that turn per island that they control, but decreases the happiness by 20 points on each of these islands.
* Investing on happiness makes the player pay 1 golden coin per each island that they control, but increase happiness levels by 20 points on each island.
* Acquiring one empty island costs 3 golden coins and decreases the happiness levels of 50% of that player's islands by half. There are a limited number of empty islands, that are defined at the beginning of the game when selecting the play style of the match. If selected friendly, there will be 3 * {number of players} empty islands available. If selected moderate, there will be 2 * {number of players} empty islands available. And if selected aggressive, there will be {number of players} empty islands.
* Attacking one player has a little bit more of nuance. If the attacker has more islands and an overall bigger happiness level (the sum of all happiness levels of the islands the player controls), then they steal the island from their victim, and acquire the city with a happiness level set to 50.
* A player automatically loses an island if the happiness level of their population reaches 0.
* A player automatically is removed from the game (loses) if they do not control any island.
* The game is over when there's only one player remaining.

Variables:
* Players
* Islands of these players
* Happiness level of each island controlled by the player (from 0 to 100)
