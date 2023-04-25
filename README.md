# Baseball Manager Simulator

Baseball manager simulator created using linux. To start the game run:

```
cd Baseball-Manager-Simulator
./manager.sh
```

## New Game

You will be prompted with the message below.

![Screenshot](/pictures/p1.png)

You can then type the team name that you want. The MLB teams printed are there for those who forget. Once the user has chosen a team name, they are prompted to choose their team one at a time by position. In this example, I choose the team name `Phillies`. A `session` file will be generated to keep track of statistics. The first line contains the `team` name. The second line contains the `win` count with the third line containing the `loss` count.

## Build Your Roster

![Screenshot](/pictures/p2.png)

The players listed are located in the `players` file. These are the top 3 position players taken from MLB The Show alogn with their ratings. The players need to be entered exactly as shown. Once all players are selected, a `roster` file will be generated that contains all selected players.

## Welcome Screen

![Screenshot](/pictures/p3.png)

You will then be redirected to the home screen. The first option is a simulated baseball game. The second option is to see the summary of those games. The third option allows you to search the players in those summary. The fourth option lets you restart your game progress by letting you build a new roster. Your `team` name and `win`-`loss` record are shown on the welcome screen and is update accordingly after every game.

## Gameplay

The simulated baseball game is simplified. At the start of every game, a random lineup is generated from the `roster` you built. The game is then simulated on an RNG basis. Your team is always the home team. At the start of every inning, the lineup is ran through until 3 outs are made. Player's ratings affect the outcome of the game. Whenever a batter faces a pitcher, the pitcher gets a random rating between 1-100. If the difference between the player's rating and the pitcher's rating falls into certain thresholds, an outcome if produced. 

For example:
Difference of less than 40 = Strikeout
Difference of less than 50 = Single
Difference of less than 60 = Double
Difference of less than 70 = Triple
Difference of less than 80 = Homerun
Else an out is recorded

If a single is recorded, everyone on base moves up one spot. For a double, everyone moves up two and so on. If a homerun is hit, the team gains runs equal to 1 + the total number of players on base. 

The enemy team is simulated using RNG. For their top of the inning, the away team can score between 1 to 3 runs. This range allows for competitive gameplay for the user.