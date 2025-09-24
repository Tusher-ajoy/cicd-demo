require('dotenv').config({ path: '.env' });
const mongoose = require('mongoose');
const User = require('../src/user.model');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/demo';

async function migrate() {
  try {
    await mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    const exists = await User.findOne({ email: 'admin@example.com' });
    if (!exists) {
      await User.create({ name: 'Admin', email: 'admin@example.com' });
      console.log('Default admin user created.');
    } else {
      console.log('Admin user already exists.');
    }
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

migrate();
