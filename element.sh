PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  # now I need to check if the argument is an atomic_number/symbol/name
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    CHECK_NUMBER=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1")
  else
    CHECK_NAME=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name='$1'")
    CHECK_SYMBOL=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1'")
  fi

  if [[ -z $CHECK_NUMBER && -z $CHECK_NAME && -z $CHECK_SYMBOL ]]
  then
    echo "I could not find that element in the database."
  else
    # now we need to see if the user input is an atomic number/symbol/name
    if [[ -n $CHECK_NUMBER ]]
    then
      ELEMENT_TABLE_INFO=$CHECK_NUMBER
    elif [[ -n $CHECK_NAME ]]
    then
      ELEMENT_TABLE_INFO=$CHECK_NAME
    else
      ELEMENT_TABLE_INFO=$CHECK_SYMBOL
    fi
    echo -e "$ELEMENT_TABLE_INFO" | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME
    do
      # with the atomic number I can get all of the info needed
      PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      echo -e "$PROPERTIES" | while IFS="|" read ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID
      do
        TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
    done
  fi
fi