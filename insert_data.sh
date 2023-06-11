#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Delete all data
echo $($PSQL "TRUNCATE TABLE games, teams;")


# Insert teams data
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # Don't include the first row
  if [[ $WINNER != "winner" && $OPPONENT != "opponent" ]]
  then
    # Check if the team is already in the database
    # It needs to check both teams, because one team could never be a winner or otherwise
    TEAM1=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    TEAM2=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    
    # Check winners column
    if [[ -z $TEAM1 ]]
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "TEAM INSERTED $WINNER"
      fi
    fi
    
    # Check opponents column
    if [[ -z $TEAM2 ]]
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "TEAM INSERTED $OPPONENT"
      fi
    fi
  fi
  
done

# Insert games data
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Don't include the first row
  if [[ $YEAR != "year" ]]
  then
  
    # Check the team's ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # Insert data
    INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    if [[ $INSERT == "INSERT 0 1" ]]
    then
      echo "INSERTED GAME: $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS"
    fi

  fi
done
