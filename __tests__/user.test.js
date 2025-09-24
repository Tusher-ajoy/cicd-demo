const mongoose = require('mongoose');
const request = require('supertest');
const app = require('../src/index');
const User = require('../src/user.model');

beforeAll(async () => {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/demo', {
    useNewUrlParser: true,
    useUnifiedTopology: true
  });
});

afterAll(async () => {
  await User.deleteMany({ email: 'test@example.com' });
  await mongoose.disconnect();
});

describe('User API', () => {
  it('should create and read a user', async () => {
    // Create user
    const res = await request(app)
      .post('/users')
      .send({ name: 'Test', email: 'test@example.com' });
    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('_id');
    expect(res.body.name).toBe('Test');
    expect(res.body.email).toBe('test@example.com');

    // Read user
    const getRes = await request(app).get('/users');
    expect(getRes.statusCode).toBe(200);
    const found = getRes.body.find(u => u.email === 'test@example.com');
    expect(found).toBeDefined();
    expect(found.name).toBe('Test');
  });
});
