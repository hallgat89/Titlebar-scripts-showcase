#!/bin/bash

#By Adam Hallgat (https://github.com/hallgat89/)

# WRITE ADDITIONAL FUNCTIONS HERE

getwid2()
{   #gets actual window id
    a=`xdotool getactivewindow`
    printf 0x%x $a #convert to wmctrl (hexa) format
}

set -e
function cleanup {
    #restore original window title  on exit (or crash)
    wmctrl -ir "$WID" -T "$WIT" &>/dev/null || :
}
trap cleanup EXIT



WID=$(getwid2) #windowid
WIT=`xdotool getactivewindow getwindowname` #window title
CWIT=$WIT #this will store the current window title
while [ "1" -eq "1" ]
do
    
    YOURTEXT="A text you want to show in the window. (maybe an output of a command)"
    
    ################################################################################
    NWID=$(getwid2)
    if [ "$NWID" != "$WID" ]
    then
        #window changed
        wmctrl -ir "$WID" -T "$WIT" &>/dev/null || :
        WID=$(getwid2)
        WIT=`xdotool getactivewindow getwindowname` &>/dev/null || :
    fi
    
    TWIT=`xdotool getactivewindow getwindowname` &>/dev/null || :
    if [ "$TWIT" != "$CWIT" ]
    then
        #title changed
        WIT=$TWIT
    fi
    ################################################################################
    
    #update title (WIT is the window title)
    CWIT="$YOURTEXT - $WIT"
    wmctrl -ir "$WID" -T "$CWIT" &>/dev/null || : #changing title
    sleep 1 #update interval in seconds
done
