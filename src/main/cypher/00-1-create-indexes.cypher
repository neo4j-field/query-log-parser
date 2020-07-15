// ==================================
// Create indexes/constraints
// ==================================

RETURN apoc.date.format(datetime().epochSeconds, 's', "yyyy-MM-dd'T'HH:mm:ssZ", 'Europe/Berlin') + ' [INFO] 00-1.1 - Creating indexes and constraints' AS ` `;

// create your indexes / constraints here

CALL db.awaitIndexes(60);

RETURN apoc.date.format(datetime().epochSeconds, 's', "yyyy-MM-dd'T'HH:mm:ssZ", 'Europe/Berlin') + ' [INFO] 00-1.1 done' AS ` `;
