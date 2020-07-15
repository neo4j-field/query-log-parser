# Query Log Parser

A bash script to quickly analyze either a 3.5 or 4.1 Neo4j query log and report the following:

* Start/End Time of the Query Log to be Analyzed
* Top 10 Slowest Queries, sorted by slowest first, based upon total Duration of the query
* Top 10 Slowest Queries, sorted by slowest first, based upon Planning Time (provided it is enbled to be logged)
* Top 10 Slowest Queries, sorted by slowest first, based upon CPU Time (provided it is enbled to be logged)
* Top 10 Slowest Queries, sorted by slowest first, based upon Waiting Time (provided it is enbled to be logged)
* With 4.1.x, Queries which have started but not completed (provided dbms.logs.query.enabled=VERBOSE)

This repository contains 2 scripts, namely

 parseq_3x_40x.sh   <-- to be used against either 3.x or 4.0.x query.log
 parseq_41x.sh      <-- to be used against a 4.1.x query.log

After copying the script to your linux/mac environment run the script as 

---
 ./<script_name> <query.log>
---

for example

---
 ./parseq_41x.sh logs/query.log
--- 
 
