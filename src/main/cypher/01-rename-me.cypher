RETURN apoc.date.format(datetime().epochSeconds, 's', "yyyy-MM-dd'T'HH:mm:ssZ", 'Europe/Berlin') + ' [INFO] 01.1 Importing ...' AS ` `;

UNWIND [
  'products-1.csv', // no spaces in folder and filenames
  'products-2.csv' // no spaces in folder and filenames
] AS filename
CALL apoc.periodic.iterate(
'
CYPHER runtime=slotted
LOAD CSV FROM "file:///products/" + $filename AS line
RETURN line
',
'
MERGE (some)-[:GRAPH]->(:Patterns)
',
{batchSize: 10000, parallel: false, iterateList: true, params: {filename: filename}}
)
YIELD batches, total, timeTaken, committedOperations, failedOperations, failedBatches, retries, errorMessages, batch, operations, wasTerminated
RETURN *;

RETURN apoc.date.format(datetime().epochSeconds, 's', "yyyy-MM-dd'T'HH:mm:ssZ", 'Europe/Berlin') + ' [INFO] 01.1 done' AS ` `;
