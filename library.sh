#!/bin/bash

if [ -f users ]
then
	file="users"
else
	touch users
	file="users"
fi

globaluser=""
catalog="catalog"
books=()

# account creation
function create() {
	printf "\n*** Acount Creation ***\n"

  local cond=0
  while [ $cond == 0 -o $cond == 1 ]; do
	if [ $cond == 0 ]
	then
  		read -p "Enter username: " username
	else
		read -p "Username already taken, please try again: " username
	fi
	cond=0
	while read items; do
		if [ "${items:0:8}" == "username" -a "${items:9}" == "$username" ]
		then
			cond=1
			break
		fi
	done < $file
	if [ $cond == 0 ] 
	then
		break
	fi
  done
  while [ $cond == 0 -o $cond == 1 ]; do
	  if [ $cond == 0 ]
	  then
		  read -s -p "Enter password: " password
	  else
		  read -s -p "Password must be at least 8 characters long and contain a number, an uppercase letter, and a lowercase letter: " password
	  fi
	  cond=0
	  if [ ${#password} -le 7 ]
	  then
		  cond=1
	  else
		  if [[ $password =~ [A-Z] ]]
		  then
			  if [[ $password =~ [a-z] ]]
			  then
				  if [[ $password =~ [0-9] ]]
				  then
					  cond=2
				  else
					  cond=1
				  fi
			  else
				  cond=1
			  fi
		  else
			  cond=1
		  fi
	  fi 
  done
  globaluser="$username"
  echo -e "username:$username" >> users
  echo -e "password:$password" >> users
}

# account login
function login() {
  printf "\n*** Account Login ***\n"

  cond=0
  read -p "Enter username: " loginuser
  read -s -p "Enter password: " loginpassword

  while read userfile; do
	first=$userfile
	read userfilenext
	second=$userfilenext
	
	cut="${first:9}"
	
	if [ "${cut,,}" == "${loginuser,,}" ] 
	then
		if [ "${second:9}" == "$loginpassword" ]
		then
			cond=1
		fi
	fi	
  done < $file
  if [ $cond == 1 ]
  then
	  globaluser="$loginuser"
	  printf "\nSuccessfully logged in as "$loginuser".\n"
	  return 0
  else
	  printf "\nFailed to login, incorrect username or password\n"
	  non_login_main
	  return 1
  fi
}

# search database
function search() {
  printf "\n*** Search Database ***\n"
  printf "To search the database by author and book title, enter \"<book title>,<name>\".\n"
  printf "To search the database by author or book title alone, use the * in place of a search term.\n"
  printf "For example, \"*,shakespeare\" will find all books by shakespeare.\n"
  printf "Hit <Enter> to return to the main menu.\n\n"

  book=""
  IFS=, read -p "What book(s) would you like to find? " -r -a response
  if [[ -n "$response" ]]
  then
	  if [ "${response[0]}" == "*" -a "${response[1]}" == "*" ]
	  then
		  while read cata || [ -n "$cata" ]; do
			  echo "$cata"
		  done < $catalog
		  
	  elif [ "${response[0]}" == "*" ]
	  then
		cut="${response[1]}"
		while read cata2; do
			short="${cata2##* by }"
			if [[ "${short,,}" =~ "${cut,,}" ]]
			then
				echo "${cata2%% (*}"
			fi
		done < $catalog
	  elif [ "${response[1]}" == "*" -a "${response[0]}" != "*" ]
	  then
		cut="${response[0]}"
		while read cata3; do
			short="${cata3%% by*}"
			if [[ "${short,,}" =~ "${cut,,}" ]]
			then
				echo "${cata3%% (*}"
			fi
		done < $catalog
	  elif [ "${response[0]}" != "*" -a "${response[1]}" != "*" ]
	  then
		  cut0="${response[0]}"
		  cut1="${response[1]}"
		  while read cata4; do
			  short0="${cata4%% by*}"
			  short1="${cata4##* by }"
			  

			  if [[ "${short0,,}" =~ "${cut0,,}" ]]
			  then
				  echo "${cata4%% (*}"
				  if [[ "${short1,,}" =~ "${cut1,,}}" ]]
				  then
					  echo "${cata4%% (*}"
			  	  fi
			  fi
		  done < $catalog
	  fi
	  search
  fi
}

function checkout() {
  printf "\n*** Checkout books ***\n"

  if [ ${#books[@]} -ge 10 ]
  then
	  printf "You have checked out the maximum number of books allowed.\n"
  else
	  IFS=, read -p "What book(s) would you like to check out? Please separate titles with a comma: " -r -a checkout

	  if [ ${#checkout[@]} -gt 10 ]
	  then
		  echo -e "You cannot checkout more than 10 books total. You have ${#books[@]} checked out now."

	  else
		  counter=0
		  for book0 in "${checkout[@]}"
		  do
			  while read cat6; do
				short1="${cat6%% by*}"
				if [[ "${short1,,}" =~ "${book0,,}" ]]
				then
					counter=$(($counter + 1))
				fi
			  done < $catalog
		  done
		  booklen=${#books[@]}

		  if [ $(($counter + $booklen)) -gt 10 ]
		  then		  

		  echo -e "You cannot checkout more than 10 books total. You have ${#books[@]} checked out now."
	  else

	  for book in "${checkout[@]}"
	  do
		  exists=0
		  while read cat5; do
			  if [ ${#books[@]} -ge 10 ]
			  then
				  exists=2
				  break
			  fi
			  short1="${cat5%% by*}"
			  if [[ "${short1,,}" =~ "${book,,}" ]]
			  then
				  exists=1
				  books+=("${cat5}")
				  echo -e "Successfully checked out "$short1"."
  			  fi
		  done < $catalog
		  if [ $exists == 0 ]
		  then
			  echo -e "Error checking out $book. Title not found. \n"
		  fi
		  exists=0
	  done
	  fi
	  fi
  fi
}

function read_book() {
  printf "\n*** Read Book ***\n"
  # TODO: Finish implementing
  printf "You have the following titles checked out:\n"
  for title in "${books[@]}"; do
	  echo "${title%% (*}"
  done
  read -p "Which book would you like to read? " choice
  if [[ -n "$choice" ]]
  then
  exists=0
  for title in "${books[@]}"; do
	short="${title%% by*}"
	if [[ "${short,,}" =~ "${choice,,}" ]]
	then
		partialid="${title##*(}"
		id="${partialid::-1}"
		exists=1
		printf "Opening "${title%% by*}"...\n"
		cd books
		if [ -f "${id}" ]
		then
			more -d "${id}"
		fi
	fi
  done
  if [ $exists == 0 ]
  then
	  printf "Error opening $choice. Title not found.\n"
  fi
  fi
}

# not logged in main menu
function non_login_main() {
  printf "Welcome to the CIS 1910 Library Database! What would you like to do?\n"
  printf "\t[1] Create account\n\t[2] Login\n\t[3] Search\n\t[<Enter> or CTRL+D] Quit\n"
  read option
  while [ ! -z "$option" ]; do
    case "$option" in
      1)
        # TODO: Create acount
	create
		logged_in_main
        ;;
      2)
        # TODO: Login 
	login
		logged_in_main
        ;;
      3)
        # TODO: Search 
	search
        ;;
      *)
        printf "Invalid option.\n"
        ;;
    esac
    printf "\nWelcome to the CIS 1910 Library Database! What would you like to do?\n"
    printf "\t[1] Create account\n\t[2] Login\n\t[3] Search\n\t[<Enter> or CTRL+D] Quit\n"
    read option
  done
  printf "Shutting down...\n"
  exit 0
}

# logged in main menu
function logged_in_main() {
	printf "\nWelcome to the CIS 1910 Library Database! You are logged in as "$globaluser". What would you like to do?\n"
  printf "\t[1] Search\n\t[2] Checkout books\n\t[3] Read book\n\t[<Enter> or CTRL+D] Quit\n"
  read option
  while [ ! -z "$option" ]; do
    case "$option" in
      1)
        # TODO: Search
	search
        ;;
      2)
        # TODO: Checkout
	checkout
        ;;
      3)
        # TODO: Read book
	read_book
        ;;
      *)
        printf "Invalid option.\n"
        ;;
    esac
    printf "\nWelcome to the CIS 1910 Library Database! You are logged in as user. What would you like to do?\n"
    printf "\t[1] Search\n\t[2] Checkout books\n\t[3] Read book\n\t[<Enter> or CTRL+D] Quit\n"
    read option
  done
  printf "Shutting down...\n"
  exit 0
}

# TODO: start the database

non_login_main



