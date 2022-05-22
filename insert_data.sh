#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Delete existing data
$($PSQL "TRUNCATE TABLE games, teams")

# Loop through all entries
cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  # Add teams
  if [[ $WINNER != "winner" ]]
  then
    # Add to database if not exists
    TEAM_ID=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")
    if [[ -z $TEAM_ID ]]
    then
      echo Team not exists, adding $WINNER
      TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi
    
  fi

  if [[ $OPPONENT != "opponent" ]]
  then
    # Add to database if not exists
    TEAM_ID=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $TEAM_ID ]]
    then
      echo Team not exists, adding $OPPONENT
      TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
  fi

  # Add Games
  if [[ $ROUND != "round" ]]
  then
    # Get Team_id winner_team
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM TEAMS WHERE name='$WINNER'")
    
    # Get Team_id opponent_team
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM TEAMS WHERE name='$OPPONENT'")

    # Create game
    echo Creating Game $ROUND $WINNER - $OPPONENT, $WINNER_GOALS : $OPPONENT_GOALS
    GAME_ID=$($PSQL "INSERT INTO games(round, year, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$ROUND', $YEAR, $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")

  fi
done
