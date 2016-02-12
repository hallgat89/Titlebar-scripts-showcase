#!/bin/bash

#By Adam Hallgat (https://github.com/hallgat89/)

getwid2 ()
{
    a=`xdotool getactivewindow` &>/dev/null || :
    printf 0x%x $a #convert to wmctrl format
}

set -e
function cleanup {
    wmctrl -ir "$WID" -T "$WIT" &>/dev/null
}
trap cleanup EXIT



WID=$(getwid2)
WIT=`xdotool getactivewindow getwindowname` &>/dev/null ||: 
CWIT=$WIT #this will store the current window title
state=0 #animation state
while [ "1" -eq "1" ]
do

    if [ "$state" -eq "0" ]
    then
        guy='(   •_• )'
    elif [ "$state" -eq "1" ]
    then
        guy='(   •_• )>⌐■-■'
    elif [ "$state" -eq "2" ]
    then
        guy='(⌐■_■)'
    fi
    
    NWID=$(getwid2)
    if [ "$NWID" != "$WID" ]
    then
        #window changed
        state=0
        guy='(   •_• )'
        wmctrl -ir "$WID" -T "$WIT" &>/dev/null || state=0 
        WID=$(getwid2)
        WIT=`xdotool getactivewindow getwindowname`&>/dev/null || state=0 
    fi
    
    TWIT=`xdotool getactivewindow getwindowname`&>/dev/null || state=0 
    if [ "$TWIT" != "$CWIT" ]
    then
        #title changed
        WIT=$TWIT
    fi
    
    if [ "$state" -lt "3" ]
    then
        state=$(($state+1))
        CWIT="$guy"
    else
        CWIT="$guy $WIT"
    fi
    wmctrl -ir "$WID" -T "$CWIT" &>/dev/null || state=0 
    
    sleep 1
done
