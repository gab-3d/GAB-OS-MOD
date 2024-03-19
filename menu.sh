#!/bin/bash

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=5
BACKTITLE="Backtitle here"
TITLE="Main Menu"
MENU="Choose one of the following options:"

OPTIONS=(1 "Option 1"
         2 "Option 2"
         3 "Option 3"
         4 "Option 4"
         5 "Option 5")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "You chose Option 1"
            # Call your shell script here
            # ./script1.sh
            ;;
        2)
            echo "You chose Option 2"
            # Call your shell script here
            # ./script2.sh
            ;;
        3)
            echo "You chose Option 3"
            # Call your shell script here
            # ./script3.sh
            ;;
        4)
            echo "You chose Option 4"
            # Call your shell script here
            # ./script4.sh
            ;;
        5)
            echo "You chose Option 5"
            # Call your shell script here
            # ./script5.sh
            ;;
esac