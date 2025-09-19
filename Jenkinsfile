pipeline {
agent { docker { image 'node:18' } }
environment { NODE_ENV = 'ci' }
stages {
stage('Checkout') { steps { checkout scm } }
stage('Install') { steps { sh 'npm ci' } }
stage('Lint') { steps { sh 'npm run lint' } }
stage('Test') { steps { sh 'npm test' } }
stage('Security') { steps { sh 'npm audit --audit-level=moderate || true' } }
stage('Migrate') { steps { sh 'npx knex migrate:latest' } }
stage('Build & Deploy') {
steps {
sh 'docker build -t demo-nodejs:latest .'
sh 'docker-compose up -d --build'
}
}
}
post { always { echo 'Pipeline finished' } }
}