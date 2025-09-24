# Node.js Demo Project

A simple Node.js demo using Express, Mongoose, Jest, and Docker.

## Features
- Express.js web server with `/health` endpoint
- Mongoose User model (name, email)
- Migration script to insert default admin user
- Jest tests for `/health` and User CRUD
- Docker and Docker Compose setup

## Project Structure
```
.
├── .env.example
├── Dockerfile
├── README.md
├── docker-compose.yml
├── docker-compose.test.yml
├── migrations/
│   └── 001_init.js
├── package.json
├── sonar-project.properties
├── src/
│   ├── index.js
│   ├── user.js
│   └── user.model.js
└── __tests__/
    ├── health.test.js
    └── user.test.js
```

## Usage

### 1. Clone and build
```bash
git clone <repo-url>
cd <project-folder>
docker-compose up --build
```

### 2. Run migrations
```bash
docker-compose exec app npm run migrate
```

### 3. Test health endpoint
Visit [http://localhost:3000/health](http://localhost:3000/health)

### 4. Run tests
```bash
docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
```

## Environment
Copy `.env.example` to `.env` and adjust as needed.

## Scripts
- `npm run start` — Start the server
- `npm run migrate` — Run migration scripts
- `npm run test` — Run Jest tests

---
- Default admin user: `admin@example.com`
- Secret key in `.env.example` is for Gitleaks detection
