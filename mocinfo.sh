#!/bin/bash

#By Adam Hallgat (https://github.com/hallgat89/)

getwid2 ()
{
    a=`xdotool getactivewindow` &>/dev/null || :
    printf 0x%x $a #convert to wmctrl format
}

#char repeater
repl() { 
            
            if [ "$2" -gt "0" ]
            then
                x=$(($2-1))
                printf "$1"'%.s' $(eval "echo {0.."$(($x))"}"); 
            else
                echo ""
            fi
} 

getmopp ()
{
    #gets state of moc player, or returns OFF
    mocs=`mocp -Q %state &>/dev/null || echo OFF`

    if [ "$mocs" == "PLAY" ]
    then
        outstring="▶ " # play symbol
    elif [ "$mocs" == "PAUSE" ]
    then
        outstring="║ " # pause symbol
    elif [ "$mocs" == "STOP" ]
    then
        outstring="■ ░░░░░░░░░░ -" # stop symbol, empty bar
    fi
    
    if [ "$mocs" == "PLAY" -o "$mocs" == "PAUSE" ]
    then
        mocpcs=`mocp -Q %cs` # current seconds
        mocpts=`mocp -Q %ts` # total seconds (can be empty - online radio)
        if [ -z "$mocpts" ]
        then
            #web radio
            outstring="▼ " #web symbol
            ec="`mocp -Q %b`kbps" #speed
            ec2=""
            #ec2=" `mocp -Q %r`kHz" #kHz
        else
            percent=`echo "scale=0; ($mocpcs*100/$mocpts)/10" | bc` #0-9
            ec=$(repl '█' $((1 + $percent))  ) # loaded █
            ec2=$(repl '░' $((9 - $percent)) ) # empty ░
        fi
        outstring="$outstring$ec$ec2 -"
    fi
    
    echo $outstring
}


set -e
function cleanup {
    #restore original window title  on exit (or crash)
    wmctrl -ir "$WID" -T "$WIT" &>/dev/null || :
}
trap cleanup EXIT



WID=$(getwid2) #windowid
WIT=`xdotool getactivewindow getwindowname` &>/dev/null || : #window title
CWIT=$WIT #this will store the current window title
while [ "1" -eq "1" ]
do
    
    mocinfo=`getmopp` # time or moc info

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
        #echo "title changed"
        WIT=$TWIT
    fi
    
    #update title
    CWIT="$mocinfo$WIT"
    wmctrl -ir "$WID" -T "$CWIT" &>/dev/null || :
    sleep 1
done
