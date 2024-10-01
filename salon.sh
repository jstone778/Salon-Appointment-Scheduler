#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n ~~~~ Salon Services Menu ~~~~"
  echo -e "\n1) Haircut\n2) Hair Coloring\n3) Manicure\n4) Pedicure\n5) Exit"
  echo -e "\nChoose one of the servies from the list above:"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE_MENU 1 ;;
    2) SERVICE_MENU 2 ;;
    3) SERVICE_MENU 3 ;;
    4) SERVICE_MENU 4 ;;
    5) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

SERVICE_MENU() {
  SERVICE_ID_SELECTED=$1
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nPlease enter your name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    echo -e "\nWelcome, $CUSTOMER_NAME. What time can we provide your $SERVICE_SELECTED for you today?"
    read SERVICE_TIME
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWelcome back, $CUSTOMER_NAME. What time can we provide your $SERVICE_SELECTED for you today?"
    read SERVICE_TIME
  fi
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  EXIT
}

EXIT() {
  echo -e "\nThank you for dropping by.\n"
}

MAIN_MENU