const knex = require('knex');
const cfg = require('../knexfile');
const env = process.env.NODE_ENV || 'development';
module.exports = knex(cfg[env]);