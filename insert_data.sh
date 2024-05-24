#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; 
do
  # Ignore the first line (header) of the CSV file
  if [[ $YEAR != "year" ]]; then
    echo "Processing game: $YEAR $ROUND $WINNER vs $OPPONENT, $WINNER_GOALS-$OPPONENT_GOALS"
    
    # Get the ID of the winning team
    echo "Getting ID for winner: $WINNER"
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    echo "Winner ID: $WINNER_ID"
    
    # If the team is not found in the database, insert it
    if [[ -z $WINNER_ID ]]; then
      echo "Winner not found in database. Inserting..."
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      echo "Inserted. New winner ID: $WINNER_ID"
    fi
    
    # Get the ID of the opposing team
    echo "Getting ID for opponent: $OPPONENT"
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    echo "Opponent ID: $OPPONENT_ID"
    
    # If the team is not found in the database, insert it
    if [[ -z $OPPONENT_ID ]]; then
      echo "Opponent not found in database. Inserting..."
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      echo "Inserted. New opponent ID: $OPPONENT_ID"
    fi
    
    # Insert the game data into the games table
    echo "Inserting game data into the database..."
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')"
    echo "Game data inserted."
  fi
    
done
