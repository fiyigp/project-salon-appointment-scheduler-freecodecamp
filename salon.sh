#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n< Coder's Salon />\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  echo "Welcome to Coder's Salon, How can I help you?"
  
  SALON_SERVICES=$($PSQL "SELECT service_id, name, price, duration FROM services ORDER BY service_id;")

  if [[ -z $SALON_SERVICES ]]
    then
      echo "Sorry, we don't have any services right now."
    else
      echo "$SALON_SERVICES" | while IFS="|" read SERVICE_ID NAME PRICE DURATION
      do
        echo "$SERVICE_ID) $NAME $PRICE $DURATION" | sed "s/^ *//" | sed "s/ )/)/" | sed "s/) /)/"
      done

      read SERVICE_ID_SELECTED
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
      if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $SERVICE_NAME ]]
        then
        SERVICE_MENU "I could not find that service. What would you like today?"
        else
        echo -e "\nWhat's your phone number?"
        
        read CUSTOMER_PHONE
        
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
        
        if [[ -z $CUSTOMER_NAME ]]
          then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          
          read CUSTOMER_NAME

          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
        fi

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

        echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?" | sed "s/  */ /g"

        read SERVICE_TIME

        INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed "s/  */ /g"

        SERVICE_MENU

      fi
  fi
}

SERVICE_MENU