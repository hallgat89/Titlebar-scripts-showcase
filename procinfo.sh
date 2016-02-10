#!/bin/bash

#By Adam Hallgat (https://github.com/hallgat89/)

getwid2()
{   #gets actual window id
    a=`xdotool getactivewindow`
    printf 0x%x $a #convert to wmctrl (hexa) format
}

getapname()
{   #gets the name of process belonging to the focused window
    WID=$(getwid2) #focused window id
    
    #xwininfo -root -tree | grep -a "$WID"
    #example: 0x2800004 "Terminál": ("xfce4-terminal" "Xfce4-terminal")  1280x758+0+22  +0+22

    name=`xwininfo -root -tree | grep -a "$WID" | cut -d"(" -f2- | cut -d'"' -f2` &>/dev/null
    echo $name
}

getprocid()
{
    id=`ps -A | grep $1 | cut -d' ' -f2` &>/dev/null
    return $id
}

getprocinfo()
{
    #returns memory and cpu info
    #inf=`ps -p $(pidof $1) -o %mem=mem,%cpu=cpuav | xargs`
    inf=`ps -p $(pidof $1) -o %mem=mem | xargs` &>/dev/null
    echo "$inf %"
}

fixname()
{
    #replaces wrongly named process names
    var=$1
    if [ "$1" == "Navigator" ]
    then
        var="firefox"
    fi
    
    echo $var
}

set -e
function cleanup {
  wmctrl -ir "$WID" -T "$WIT" &>/dev/null || :
}
trap cleanup EXIT


WID=$(getwid2)
NAME=$(getapname)
WIT=`xdotool getactivewindow getwindowname`
CWIT=$WIT #this will store the current window title
while [ "1" -eq "1" ]
do

    #time=`date +"%T"`
    NWID=$(getwid2)
    NAME=$(getapname)
    NAME=$(fixname $NAME)
    inf=$(getprocinfo $NAME)
    if [ "$NWID" != "$WID" ]
    then
        #echo "window changed"
        wmctrl -ir "$WID" -T "$WIT" &>/dev/null  || : #restore old window title
        WID=$NWID
        WIT=`xdotool getactivewindow getwindowname` &>/dev/null || :
    fi
    
    TWIT=`xdotool getactivewindow getwindowname`  &>/dev/null || :
    if [ "$TWIT" != "$CWIT" ]
    then
        #echo "title changed"
        WIT=$TWIT #update title
    fi

    
    CWIT="[$NAME - $inf] - $WIT"
    wmctrl -ir "$WID" -T "$CWIT" &>/dev/null || :
    sleep 2
done

