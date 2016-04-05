var liner = require('./lib/liner.js');

process.stdin.pipe(liner).pipe(process.stdout);

