#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#number_guessing_game_function
number_guessing() {
  #generate a random number
  number=$(( RANDOM % 1000 + 1 ))

  #asking for the guess
  echo Guess the secret number between 1 and 1000:
  
  #checking the guesses
  while true; do
  read guess

  #count the number of guesses
   (( counter ++ ))

  #if the guess is not an integer
  if ! [[ $guess =~ ^[0-9]+$ ]]; then
   echo "That is not an integer, guess again:" 
   continue
  fi
 
  #guess checking
  #if the guess is correct
  if [ $guess -eq $number ]; then
  echo You guessed it in $counter tries. The secret number was $number. Nice job!
  break
  #if the guess is lower than the answer
  elif [[ $guess -lt $number ]]; then
   echo "It's higher than that, guess again:"
  #if the guess is higher than the answer
  else
   echo "It's lower than that, guess again:"
  fi
  done

}

echo Enter your username:
read username

#get player id
player_id=$($PSQL "SELECT player_id FROM players WHERE username = '$username'")

#check if the username has been used 
#if the username hasn't been used
if [[ -z $player_id ]]; then
echo Welcome, $username! It looks like this is your first time here.
#insert username of the new player
insert_username=$($PSQL "INSERT INTO players(username) VALUES('$username')")
#get new player id
new_player_id=$($PSQL "SELECT player_id FROM players WHERE username = '$username'")
#start the game
number_guessing
#insert new game history
insert_new_game=$($PSQL "INSERT INTO games(player_id, number_of_guesses) VALUES($new_player_id, $counter)")

#if the username has been used
else 
games_played=$($PSQL "SELECT COUNT(username) FROM games JOIN players USING(player_id) WHERE username = '$username'")
best_game=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE player_id = $player_id")
echo Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses.
#start the game
number_guessing
#insert new game history
insert_new_game=$($PSQL "INSERT INTO games(player_id, number_of_guesses) VALUES($player_id, $counter)")
fi