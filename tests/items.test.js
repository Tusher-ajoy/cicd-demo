const request = require('supertest');
const app = require('../server');
const db = require('../src/db');


beforeAll(async () => {
await db.migrate.latest();
await db('items').insert([{ name: 'one' }, { name: 'two' }]);
});


afterAll(async () => {
await db.destroy();
});


test('GET /health', async () => {
const res = await request(app).get('/health');
expect(res.statusCode).toBe(200);
expect(res.body).toHaveProperty('status', 'ok');
});


test('GET /items', async () => {
const res = await request(app).get('/items');
expect(res.statusCode).toBe(200);
expect(Array.isArray(res.body)).toBe(true);
expect(res.body.length).toBeGreaterThanOrEqual(2);
});