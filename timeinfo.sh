#!/bin/bash

#By Adam Hallgat (https://github.com/hallgat89/)

getwid2 ()
{
    a=`xdotool getactivewindow`
    printf 0x%x $a #convert to wmctrl format
}

set -e
function cleanup {
    #restore original title on exit (or crash)
    wmctrl -ir "$WID" -T "$WIT" &>/dev/null || :
}
trap cleanup EXIT



WID=$(getwid2) #active window id
WIT=`xdotool getactivewindow getwindowname` # original window title
CWIT=$WIT #this will store the current window title
while [ "1" -eq "1" ]
do
    
    time=`date +"%T"`
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
        # title changed
        WIT=$TWIT
    fi
    
    # set title
    CWIT="[$time] - $WIT"
    wmctrl -ir "$WID" -T "$CWIT" &>/dev/null || :
    sleep 1
done
