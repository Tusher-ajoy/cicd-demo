// Simple unit test that doesn't require database
const request = require('supertest');

// Mock the database models to avoid connection issues
jest.mock('../src/user.model', () => ({
  find: jest.fn().mockResolvedValue([]),
  findById: jest.fn().mockResolvedValue(null),
  create: jest.fn().mockResolvedValue({
    _id: 'test-id',
    name: 'Test User',
    email: 'test@example.com'
  }),
  deleteMany: jest.fn().mockResolvedValue({})
}));

const app = require('../src/index');

describe('Application Basic Tests', () => {
  it('should respond to health check', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'OK');
  });

  it('should handle user routes without database', async () => {
    const res = await request(app).get('/users');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('should accept POST requests to users endpoint', async () => {
    const res = await request(app)
      .post('/users')
      .send({ name: 'Test', email: 'test@example.com' });
    
    // Should not fail with 500 error
    expect(res.statusCode).toBeGreaterThanOrEqual(200);
    expect(res.statusCode).toBeLessThan(500);
  });
});