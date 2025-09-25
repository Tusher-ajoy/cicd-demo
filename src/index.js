require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const userRouter = require('./user');

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/users', userRouter);

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/demo';

// Only connect to MongoDB if not in test environment
if (process.env.NODE_ENV !== 'test') {
  mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => {
      app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
      });
    })
    .catch(err => {
      console.error('MongoDB connection error:', err);
      process.exit(1);
    });
} else {
  // In test environment, don't auto-connect to database
  console.log('Test environment detected, skipping automatic database connection');
}

module.exports = app;
