#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Vaciar las tablas antes de insertar nuevos datos
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

# Leer el archivo games.csv y procesar los datos
cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Saltar la primera línea (encabezado)
  if [[ $YEAR != "year" ]]
  then
    # Insertar equipos únicos
    for TEAM in "$WINNER" "$OPPONENT"
    do
      # Verificar si el equipo ya está en la tabla teams
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM';")
      # Si no está, insertarlo
      if [[ -z $TEAM_ID ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM');")
        if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
        then
          echo "Inserted team: $TEAM"
        fi
      fi
    done
    
    # Obtener los IDs de los equipos
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    
    # Insertar los datos del juego en la tabla games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $YEAR $ROUND - $WINNER vs $OPPONENT"
    fi
  fi
done
