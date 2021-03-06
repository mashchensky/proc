#!/bin/bash
proc_num=$(ls /proc/ | grep [0-9] | sort -n)
proces=1
empty=""
echo "  PID TTY      STAT   TIME COMMAND"
for proces in $proc_num
    do
    if [ -e /proc/$proces/ ]
    then
        min=0
        sec=0

        stats=$(sed 's/([^()]*)/name/' /proc/$proces/stat | awk '{print $3 " " $7 " " $14 " " $15}')
        stats=($stats)

        command=$(tr -d '\0' </proc/$proces/cmdline)
        command=${command:0:60}
        if [ -z "$command" ]
        then
            command=[$(cat /proc/$proces/comm)]
        fi

        stat=${stats[0]}
        stat="$stat     "

        clk_tck=$(getconf CLK_TCK)

        utime=${stats[2]}
        stime=${stats[3]}
        time_sec=$(($utime / $clk_tck + $stime / $clk_tck))
        min=$(($time_sec / 60))
        sec=$(($time_sec % 60))
        if (($sec <= 9))
        then
            sec="0$sec"
        fi
        time="$min:$sec"
    
        tty_nr=${stats[1]}
        if (($tty_nr >= 1024))
        then
            if (($tty_nr <= 1151))
            then
                tty=$(($tty_nr - 1024))
                tty="tty$tty    "
            else
                tty=$(($tty_nr - 34816))
                tty="pts/$tty   "
            fi
        else
            tty="?       "
        fi

        case ${#proces} in
            1)
                proces="    "$proces
                ;;
            2)
                proces="   "$proces
                ;;
            3)
                proces="  "$proces
                ;;
            4)
                proces=" "$proces
                ;;
        esac
        echo "$proces $tty $stat $time $command"
    fi
done
