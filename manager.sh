#!/bin/bash

roster="roster"
teams="teams"
players="players"

win=$(head -3 session | tail -1)
loss=$(head -4 session | tail -1)
team=$(head -2 session | tail -1)

function start_game() {
	printf "\nStarting game...\n"
	printf "\nGenerating lineup...\n"
	
	tail -n -9 roster > temp_lineup 
	sort -R temp_lineup > actual_lineup
	rm temp_lineup
	actual_lineup="actual_lineup"
	lineup=()

	count=1
	while read lineup0; do
		echo "[$count] ${lineup0%%,*}"
		lineup+=("${lineup0%%,*}")
		count=$[$count + 1]
	done < $actual_lineup
	
	inning=2
	home=0
	away=0
	while [[ $inning -lt 19 ]]; do
		rem=$((inning%2))
		inn=$[inning / 2]
		if [ $rem == "1" ]; then
			printf "\nBottom of the $inn inning\n"
			
			outs=0
		base1=0
		base2=0
		base3=0
		while [[ $outs -lt 3 ]]; do
			for player in "${lineup[@]}"
			do
				if [[ $outs == 3 ]]; then
					break
				fi
				printf "\n$player is batting...\n"
				while read lineup1; do
					enemy_pitcher=$((1 + $RANDOM % 100))
					if [[ $outs == 3 ]]; then
						break
					fi
					if [[ $lineup1 == *"$player"* ]]; then
						IFS=, read -a statline <<< $lineup1
						stat="${statline[2]}"
						diff=$((stat - enemy_pitcher))
						
						if [[ ${diff#-} -lt 40 ]]; then
							printf "$player struckout...\n"
							outs=$((outs + 1))
						elif [[ ${diff#-} -lt 50 ]]; then
							printf "$player singled...\n"
							base1=1
							if [[ $base3 == 1 ]]; then
								home=$[home + 1]
								base3=0
							fi
							if [[ $base2 == 1 ]]; then
								base2=0
								base3=1
							fi
							if [[ $base1 == 1 ]]; then
								base2=1
								base1=1
							fi
						elif [[ ${diff#-} -lt 50 ]]; then
							printf "$player doubled....\n"
							base2=1
							
							if [[ $base3 == 1 ]]; then
								home=$[home + 1]
								base3=0
							fi
							if [[ $base2 == 1 ]]; then
								home=$[home + 1]
								base2=0
							fi
							if [[ $base1 == 1 ]]; then
								base3=1
								base1=0
							fi
						
						elif [[ ${diff#-} -lt 60 ]]; then
							printf "$player tripled....\n"
							base3=1
							
							if [[ $base3 == 1 ]]; then
								home=$[home + 1]
								base3=0
							fi
							if [[ $base2 == 1 ]]; then
								home=$[home + 1]
								base2=0
							fi
							if [[ $base1 == 1 ]]; then
								home=$[home + 1]
								base1=0
							fi
						
						elif [[ ${diff#-} -lt 70 ]]; then
							printf "$player homered....\n"
							home=$[home + 1]
							base1=0
							base2=0
							base3=0
							
							if [[ $base3 == 1 ]]; then
								home=$[home + 1]
							fi
							if [[ $base2 == 1 ]]; then
								home=$[home + 1]
							fi
							if [[ $base1 == 1 ]]; then
								home=$[home + 1]
							fi
						
						elif [[ ${diff#-} -lt 100 ]]; then
							printf "$player made an out...\n"
							outs=$((outs + 1))
						fi
					fi
				done < $actual_lineup
			done	
		done
		inning=$[inning + 1]
		
		elif [ $inn != 0 ]; then
			printf "\nTop of the $inn inning\n"
			random_runs=$(($RANDOM % 3))
			away=$((away + random_runs))
			inning=$[inning + 1]
			printf "\nAway team scored $random_runs runs...\n"
		fi
	done
	printf "\n\nFinal Score:\n"
	echo "away:$away"
	echo "$team: $home"
	start_manager
}

function search() {
	printf "\n***Search Players***\n"
	printf "To search for players by first and last name, enter \"<Last Name>,<First Name>\".\n"
	printf "To search the database by first or last name, use the * in place of a search term.\n"
	printf "<Enter> returns you to the main menu.\n\n"
	
	IFS=, read -p "What player would you like to look up? " -r -a response
#	if [[ -n "$response" ]]
#	then
#		if [ "${response[0]}" == "*" -a "${response[1]}" == "*" ]
#		then
#		elif [ "${response[0]}" == "*" ]
#		then
#		elif [ "${response[0]}" != "*" -a "${response[1]}" == "*" ]
#		then
#		elif [ "${response[0]}" != "*" -a "${response[1]}" != "*" ]
#		then
#		fi
#		search
#	fi
}

function start_manager() {
	win=$(head -3 session | tail -1)
	loss=$(head -4 session | tail -1)
	team=$(head -2 session | tail -1)

	printf "\nWelcome to Baseball Manager 1910! Your current team is the $team! Your record is $win - $loss. Select an option to begin your experience.\n"
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
		printf "\nWelcome to Baseball Manager 1910! Your current team is the $team! Your record is $win - $loss Select an option to begin your experience.\n"
		printf "\t[1] Start Game\n\t[2] Stats\n\t[3] Search\n\t[<Enter> or CTRL+D] Quit\n"
		read option
	done
	printf "Closing game...\n"
	exit 0
}

function build_lineup() {
	printf "\nCatchers:\n"
	while read cata3; do
		if [[ $cata3 == *",C,"*  ]]; then
			shorter="${cata3%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Catcher: " -r -a catchers
	printf "\n"


	printf "\nFirst Baseman:\n"
	while read cata4; do
		if [[ $cata4 == *",1B,"*  ]]; then
			shorter="${cata4%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 First Basemen: " -r -a first
	printf "\n"

	printf "\nSecond Baseman:\n"
	while read cata5; do
		if [[ $cata5 == *",2B,"*  ]]; then
			shorter="${cata5%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Second Basemen: " -r -a second
	printf "\n"

	printf "\nThird Baseman:\n"
	while read cata6; do
		if [[ $cata6 == *",3B,"*  ]]; then
			shorter="${cata6%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Third Basemen: " -r -a third
	printf "\n"

	printf "\nShortstop:\n"
	while read cata12; do
		if [[ $cata12 == *",SS,"*  ]]; then
			shorter="${cata12%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Shortstop: " -r -a ss
	printf "\n"

	printf "\nLeft Fielders:\n"
	while read cata7; do
		if [[ $cata7 == *",LF,"*  ]]; then
			shorter="${cata7%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Left Fielders: " -r -a left
	printf "\n"

	printf "\nCenter Fielders:\n"
	while read cata8; do
		if [[ $cata8 == *",CF,"*  ]]; then
			shorter="${cata8%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Center Fielders: " -r -a center
	printf "\n"

	printf "\nRight Fielders:\n"
	while read cata9; do
		if [[ $cata9 == *",RF,"*  ]]; then
			shorter="${cata9%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Right Fielders: " -r -a right
	printf "\n"

	printf "\nDesignated Hitter:\n"
	while read cata10; do
		if [[ $cata10 == *",DH,"*  ]]; then
			shorter="${cata10%%,*}"
			echo "$shorter"
		fi
	done < $players
	IFS=, read -p "Please select 1 Designated Hitters: " -r -a dh

	printf "\nThank you... Setting up team...\n"
	
	while read cata11; do
		if [[ $cata11 == *"$catchers"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$first"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$second"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$third"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$left"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$center"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$right"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cata11 == *"$dh"* ]]; then
			echo "$cata11" >> roster
		elif [[ $cat11 == *"$ss"* ]]; then
			echo "$cata11" >> roster
		fi
	done < $players
	start_manager
}

function select_team() {
	printf "\nPlease select a team to get started!\n"
	COUNTER=0
	while read teams; do
		echo -e "$teams"
		COUNTER=$[COUNTER + 1]
	done < $teams
	printf "\n"
	read -p "Enter team name:" -r -a team
	printf "\n"
	touch session
	echo "0" >> session
	echo "$team" >> session
	echo "0" >> session
	echo "0" >> session
	build_lineup
}

# Start the game

if [ -f session ]
then
	start_manager
else
	select_team
fi
