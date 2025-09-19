const path = require('path');
module.exports = {
development: {
client: 'sqlite3',
connection: { filename: path.join(__dirname, 'dev.sqlite3') },
migrations: { directory: path.join(__dirname, 'migrations') },
useNullAsDefault: true
},
test: {
client: 'sqlite3',
connection: { filename: ':memory:' },
migrations: { directory: path.join(__dirname, 'migrations') },
useNullAsDefault: true
}
};