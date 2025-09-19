const express = require('express');
const db = require('./src/db');
const app = express();
app.use(express.json());


app.get('/health', (req, res) => res.json({ status: 'ok' }));


app.get('/items', async (req, res) => {
const items = await db('items').select('*').limit(100);
res.json(items);
});


app.post('/items', async (req, res) => {
const [id] = await db('items').insert({ name: req.body.name });
res.status(201).json({ id });
});


const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server listening on ${port}`));
module.exports = app; // for tests