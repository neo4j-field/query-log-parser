# Query Log Parser

A bash script to quickly analyze either a 3.5 or 4.x Neo4j query log and report the following:

* Start/End Time of the Query Log to be Analyzed
* Top 10 Slowest Queries, sorted by slowest first, based upon total Duration of the query
* Top 10 Slowest Queries, sorted by slowest first, based upon Planning Time (provided it is enbled to be logged)
* Top 10 Slowest Queries, sorted by slowest first, based upon CPU Time (provided it is enbled to be logged)
* Top 10 Slowest Queries, sorted by slowest first, based upon Waiting Time (provided it is enbled to be logged)
* With 4.1.x Show Queries which have started but not completed ( provided conf/neo4j.conf dbms.logs.query.enabled=VERBOSE)




This repository contains 2 scripts, namely

````
 parseq_3x.sh   <-- to be used against either 3.x query.log
 parseq_4x.sh      <-- to be used against a 4.x query.log
````

After copying the script to your linux/mac environment run the script as 

````
 ./<script_name> <query.log>
````

for example

````
 ./parseq_4x.sh logs/query.log
````
Example output can be found at https://github.com/neo-technology-field/query-log-parser/blob/master/sample_output.txt

What can these output tell you
  1. How many queries they run during the query.log
  2. The avg duration/time for all queries in the query.log
  3. Quickly find the longest queries
  
  4. Determine if queries are slow as a result of planning time.  Why??  Maybe the data in the graph is changing rapidly
  
  5. Determine if queries are slow as a result of CPU time.
  
  6. Determine if queries are slow as a result of Waiting time.   Why?? Maybe we have a locking contention concern?

 
*Note:*  With 4.1.x the ability to check for queries started but not completed is not a perfect science.  
It is based upon when a query is started the log entry reports a queryID, for example

````
2020-07-02 19:59:32.861+0000 INFO  Query started: id:3 - 0 ms: 0 B - bolt-session       bolt    neo4j-java/dev          client/127.0.0.1:57786  server/127.0.0.1
:7687>  <none> -  - CALL dbms.routing.getRoutingTable($context, $database) - {context: {}, database: <null>} - runtime=null - {}
````

and to which the reference to `id:3` is the queryID.  The text `Query started:` indicates the query was submitted.
The queryID number is incremental, starting at 1, and reset back to 1 on Neo4j restart.

When the Query completes we would expect a query.log line similar to

````
2020-07-02 19:59:32.904+0000 INFO  id:3 - 43 ms: -1 B - bolt-session    bolt neo4j-java/dev          client/127.0.0.1:57786  server/127.0.0.1:7687>  system -
  - CALL dbms.routing.getRoutingTable($context, $database) - {context: {}, database: <null>} - runtime=system - {}
````

The ability to detect a query started but not completed is simply to find 2 rows similar to above.  If there is a Neo4j restart in the middle of the query.log then
detection might not be perfect.

### Requirements

On MacOS to properly execute the script you need to install `gakw`, you can execute the following command if you have brew installed: 

```
brew install gawk
```
