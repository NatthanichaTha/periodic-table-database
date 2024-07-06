#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # check if $1 is atomic number/symbol/name and get info from db
  if [[ $1 =~ ^[0-9]+$ ]]; then
    NUMBER=$1
    INFO=$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number=$NUMBER")
    SYMBOL=$(echo $INFO | cut -d "|" -f 1)
    NAME=$(echo $INFO | cut -d "|" -f 2)

  elif [[ $1 =~ ^[a-zA-Z]{1,2}$ ]]; then
    SYMBOL=$1
    INFO=$($PSQL "SELECT atomic_number, name FROM elements WHERE symbol='$SYMBOL'")
    NUMBER=$(echo $INFO | cut -d "|" -f 1)
    NAME=$(echo $INFO | cut -d "|" -f 2)

  else
    NAME=$1
    INFO=$($PSQL "SELECT atomic_number, symbol FROM elements WHERE name='$NAME'")
    NUMBER=$(echo $INFO | cut -d "|" -f 1)
    SYMBOL=$(echo $INFO | cut -d "|" -f 2)
  fi

  #if not found
  if [[ -z $NUMBER || -z $SYMBOL || -z $NAME ]]; then
    echo "I could not find that element in the database."
  else
    #get element properties
    PROPERTIES=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN types USING(type_id) WHERE atomic_number=$NUMBER") 
    TYPE=$(echo $PROPERTIES | cut -d "|" -f 1)
    MASS=$(echo $PROPERTIES | cut -d "|" -f 2)
    MELTING_POINT=$(echo $PROPERTIES | cut -d "|" -f 3)
    BOILING_POINT=$(echo $PROPERTIES | cut -d "|" -f 4)
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
