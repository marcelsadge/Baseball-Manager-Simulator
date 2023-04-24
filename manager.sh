#!/bin/bash

function start_manager() {
	printf "\nWelcome to Baseball Manager 1910! Select an option to begin your experience.\n"
	printf "\t[1] Start Game\n\t[2] Stats\n\t[3] Search\n\t[<Enter> or CTRL+D] Quit\n"
	read option
	while [ ! -z "$option" ]; do
		case "$option" in 
			1)
				start_game
				;;
			2)
				stats
				;;
			3)
				search
				;;
			*)
				printf "Invalid option.\n"
		esac
		printf "\nWelcome to Baseball Manager 1910! Select an option to begin your experience.\n"
		printf "\t[1] Start Game\n\t[2] Stats\n\t[3] Search\n\t[<Enter> or CTRL+D] Quit\n"
		read option
	done
	printf "Closing game...\n"
	exit 0
}

# Start the game

start_manager
