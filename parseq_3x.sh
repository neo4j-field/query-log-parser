#!/bin/bash
# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.

# only parse those lines where the 2rd field is 'INFO'
# count total number of lines in query.log which report INFO in the 3rd field


detect_os() {
  if uname -s | grep -q Darwin; then
      DIST_OS="macosx"
      elif [[ -e /etc/gentoo-release ]]; then
           DIST_OS="gentoo"
      else
           DIST_OS="other"
  fi
  }


parse() {
logfile=$1
if [ -e $logfile ]; then
    # log file exits
    starttime=`awk '$3== "INFO" {print $1 " " $2}' $logfile | head -1`
    endtime=`awk '$3== "INFO" {print  $1 " " $2}' $logfile | tail -1`
    printf "First Query Reported at: $starttime\n"
    printf " Last Query Reported at: $endtime\n"


    detect_os

    starttimeepoc=`date "+%s" -d "$starttime"`
    endtimeepoc=`date "+%s" -d "$endtime"`
    diff=`expr $endtimeepoc - $starttimeepoc`

    dur=` echo " $(($diff / 3600)) hours, $((($diff / 60) % 60)) minutes and $(($diff % 60)) seconds."`
    printf "        Duration of Log: $dur\n"

    awk '$3== "INFO" {count++;  total=total+$4 } END{print "\n*******EXECUTION:******* \nTotal # of Completed Queries: " count "\n       Total Duration (msec): " total "\n   Avg of all Queries (msec): " total/count "\n" }' $logfile

    # print longest query
    printf "Top 10 Longest Queries longest on top and leading line number: \n"
    printf "Note: Queries which are multi-line will only report first line of query !!!\n\n\n"
    awk '$3== "INFO" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 5 | head -10

    pcw=`grep "INFO" $logfile | grep "(planning:" | head -1`
    if [ ! -z "$pcw" ]; then
          # only enter this block if conf/neo4j.conf has
          #     dbms.logs.query.time_logging_enabled=true
          # which thus causes field 6 to appear as `(planning:...........`
          #
          # produce metrics on planning, CPU and waiting
          #PLANING
          awk '$3== "INFO" && $6== "(planning:" {count++;  total=total+$7 } $7== "0," {planzero++;} END{print "\n\t\t*******PLANNING:******* \n Total # of Completed Queries: " count "\n        Total Duration (msec): " total "\n    Avg of all Queries (msec): " total/count "\nNumber of Queries NOT Planned: " planzero "    " (planzero/count)*100 "%\n" }' $logfile

          # print longest query
          awk '$3== "INFO" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 8 | head -10



          #CPU
          awk '$3== "INFO" && $8== "cpu:" {count++;  total=total+$9 } END{print "\n\t\t*******CPU:******* \nTotal # of Completed Queries: " count "\n       Total Duration (msec): " total "\n   Avg of all Queries (msec): " total/count "\n" }' $logfile
awk '$3== "INFO" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 10 | head -10



          #WAITING
          awk '$3== "INFO" &&$10== "waiting:" {count++;  total=total+$11 } $11== "0)" {nowait++;} END{print "\n\t\t\t*******WAITING:******* \n Total # of Completed Queries: " count "\n        Total Duration (msec): " total "\n    Avg of all Queries (msec): " total/count "\nNumber of Queries NOT Waiting: " nowait "      " (nowait/count)*100 "%\n" }' $logfile
awk '$3== "INFO" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 12 | head -10
     fi
          #Histogram
          printf "\n\n\n"
          printf "Historgram of Completed Queries per hour (and TZ from query.log file)\n"
          grep INFO $logfile | grep -v "Query started" | awk -F"[ :]" '{printf "%s%02d\n",$1" "$2 ":",60*int($3/60)}' | awk -F '|' '{a[$1] += 1} END{ n=asorti(a, sorted) ;  for ( i=1; i<=n; i++) print sorted[i], a[sorted[i]] }'
else
    # logfile does not exist
    printf "\n$logfile does not exist\n"
    printf "Usage: $0 <filename>\n"
fi
}

if [ -z $1 ]; then
        parse "query.log"
  else
        parse $1
fi
