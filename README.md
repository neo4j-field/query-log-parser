# Cypher LOAD CSV Import Template

A template / skeleton to quickly start a new `LOAD CSV` import project.

It takes into account the following cases:

* Import large csv files (batching is applied).
* Multiple csv files can be processed by the same cypher code.
  * This might be helpful e.g. if you receive one big table divided into multiple csv files.
* Executing all cypher files in alphabetic order.
  * This might be helpful e.g. if you have multiple cypher files that need to be processed during the import.
* Print the date, time and a custom tag line for each import file/command.
  * This might be helpful e.g. if you need to keep track of the status during long running import jobs.

## Structure

* `src/main/bin` - contains the bash import script that can be used to execute all cypher files in `src/main/cypher` 
* `src/main/cypher` - your cypher import files
  * The files are named in the order in which they need to be executed. '00-0-*' comes before '00-1-*' which comes before '01-*' and so on.
  * Rename them so that the names make sense for your specific case.
  * Rename `00-0-remove-graph.skip` into `00-0-remove-graph.cypher` if you want to remove your graph before importing.

## Getting Started

* Place your csv files in the `import` folder of your Neo4j installation.
* Adjust the cypher files in `src/main/cypher` to your needs.
* Start the bash script `src/main/bin/import.sh` (see the Usage message for more details).

## Dependencies

* Uses Cypher:
  * `cypher-shell` from the Neo4j installation.
  * `LOAD CSV`
  * `datetime()`
  * `db.awaitIndexes()`
  * `CYPHER runtime=slotted`
  * Tested with Neo4j 3.5
* Uses APOC:
  * `apoc.date.format`
  * `apoc.periodic.iterate`
  * `apoc.schema.assert`
  * Tested with APOC 3.5.0.5
* The `import.sh` bash script is meant to be run on unix systems, but it worked for me also on Windows. Test it your-self, please.
