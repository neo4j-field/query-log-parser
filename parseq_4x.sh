#!/bin/bash
function summary() {
    logfile=$1
    starttime=`awk '$3== "INFO" {print $1 " " $2}' $logfile | head -1`
    endtime=`awk '$3== "INFO" {print  $1 " " $2}' $logfile | tail -1`
    printf "First Query Reported at: $starttime\n"
    printf " Last Query Reported at: $endtime\n"
    starttimeepoc=`date "+%s" -d "$starttime"`
    endtimeepoc=`date "+%s" -d "$endtime"`
    diff=`expr $endtimeepoc - $starttimeepoc`
    dur=` echo " $(($diff / 3600)) hours, $((($diff / 60) % 60)) minutes and $(($diff % 60)) seconds."`
    printf "        Duration of Log: $dur\n"
    awk '$3== "INFO" && $4!="Query" {count++;  total=total+$6 } END{print "\n*******EXECUTION:******* \nTotal # of Completed Queries: " count "\n       Total Duration (msec): " total "\n   Avg of all Queries (msec): " total/count "\n" }' $logfile
    # print longest query
    printf "Top 10 Longest Queries longest on top and leading line number: \n"
    printf "Note: Queries which are multi-line will only report first line of query !!!\n\n\n"
    awk '$3== "INFO" && $4!="Query" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 7 | head -10
}
function cpu() {
    logfile=$1
    pcw=`grep "INFO" $logfile | grep "(planning:" | head -1`
    if [ ! -z "$pcw" ]; then
          # only enter this block if conf/neo4j.conf has
          #     dbms.logs.query.time_logging_enabled=true
          # which thus causes field 6 to appear as `(planning:...........`
          #
          # produce metrics on planning, CPU and waiting
          #PLANING
          awk '
                  $3== "INFO" && $4!="Query" && $10== "cpu:" {
                        count++;
                        total=total+$11
                  }
                  END {
                      print "\n\n*******CPU:******* "
                      print "Total # of Completed Queries: " count
                      print "Total Duration (msec): " total
                      print "Avg of all Queries (msec): " total/counta "\n"
              }' $logfile
          # print longest query
          awk '$3== "INFO" && $4!="Query" && $10== "cpu:" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 12 | head -10
       fi
}
function planning() {
    logfile=$1
    pcw=`grep "INFO" $logfile | grep "(planning:" | head -1`
    if [ ! -z "$pcw" ]; then
          # only enter this block if conf/neo4j.conf has
          #     dbms.logs.query.time_logging_enabled=true
          # which thus causes field 6 to appear as `(planning:...........`
          #
          # produce metrics on planning, CPU and waiting
          #PLANING
          awk '
                  $3== "INFO" && $4!="Query" && $8== "(planning:" {
                        count++;
                        total=total+$9
                  }
                  $9== "0," {
                     planzero++;
                  } END {
                      print "\n\n*******PLANNING:******* "
                      print "Total # of Completed Queries: " count
                      print "Total Duration (msec): " total
                      print "Avg of all Queries (msec): " total/count
                      print "Number of Queries NOT Planned: " planzero "    " (planzero/count)*100 "%\n"
              }' $logfile
          # print longest query
          awk '$3== "INFO" && $4!="Query" {print "line:" NR "\t" $0}' $logfile | sort -n -r -k 10 | head -10
       fi
}
function waiting() {
    logile=$1
    pcw=`grep "INFO" $logfile | grep "(planning:" | head -1`
    if [ ! -z "$pcw" ]; then
          # only enter this block if conf/neo4j.conf has
          #     dbms.logs.query.time_logging_enabled=true
          # which thus causes field 6 to appear as `(planning:...........`
          #
          # produce metrics on planning, CPU and waiting
          #PLANING
          awk '{   if ( $3== "INFO" && $4!="Query" && $12== "waiting:" )
                      {
                        count++
                        total=total+$13;
                      }
                    if ( $3== "INFO" && $4!="Query" && $10== "waiting:" )
                      {
                        count++
                        total=total+$11;
                      }
               } END {
                          print "\n\n*******WAITING:******* "
                          print "Total # of Completed Queries: " count
                          print "Total Duration (msec): " total
                          print "Avg of all Queries (msec): " total/count "\n" ;
      }' $logfile
          # print longest query
          awk '$3== "INFO" && $4!="Query" && $12== "waiting:"  {print $13 " line:" NR  "\t" $0} $3== "INFO" && $4!="Query" && $10== "waiting:"  {print $11 " line:" NR "\t" $0}     ' $logfile | sort -n -r -k 1 | cut -d ' ' -f 2- |  head -10
       fi
}


function missing() {
    logfile=$1
PID=$$
startFile="startedQ.$PID"
completedFile="completedQ.$PID"
errorFile="errorQ.$PID"
rm -f $startFile
rm -f $completedFile
rm -f $errorFile
# find queries which have 'Query started:'
grep "INFO" $logfile | grep "Query started: " | awk '{print $6}' | cut -d ":" -f 2 | sort -r -n > $startFile
# find queries which have completed
grep "INFO" $logfile | grep -v "Query started: " | awk '{print $4}' |  cut -d ":" -f 2 | sort -r -n > $completedFile
# find queries which reported ERROR
grep "ERROR" $logfile | grep -v "Query started: " | awk '{print $4}' |  cut -d ":" -f 2 | sort -r -n > $errorFile
started_num=`wc -l $startFile | cut -d ' ' -f 1`
completed_num=`wc -l $completedFile | cut -d ' ' -f 1`
error_num=`wc -l $errorFile | cut -d ' ' -f 1`
num_of_starts=`grep -w "1" $startFile | wc -l`
printf "\n\n\n"
printf "Number of Neo4j Starts detected: $num_of_starts     (if > 1 results may be questionable)\n"
printf "Number of queries started: $started_num\n"
printf "Number of queries compleed: $completed_num\n"
printf "Number of queries reporting ERROR: $error_num\n"
if [ $started_num != 0 ]
then
   printf "Queries which started but did not complete ( these may include queries which syntactically errored ) \n"
   printf "  * Additionally queries which started in query.log.1 may be completed in query.log and this script does not\n"
   printf "    span multiple logs\n"
   printf "  * Also since we are simply matching on a query id, and to which this can be re-cycled/re-used when Neo4j\n"
   printf "    restarts, if multiple restarts reported above then accuracy is in question.\n\n"
   printf "Started Query Id \t\t\t\t Completed Query Id:\n"
   diff --side-by-side --suppress-common-lines $startFile $completedFile
fi
printf "\n\nTo further analyze above query ids one can run from the linux prompt \`grep \" id:<id> \" query.log\`"
printf "\nfor example \`grep -n \" id:7 \" $logfile\n"
printf "\n\n\n"
printf "Files left behind include $startFile, $completedFile, $errorFile \n\n\n"
}

summary $1
planning $1
cpu $1
waiting $1
missing $1
