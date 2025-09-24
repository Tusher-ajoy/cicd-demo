# Jenkins Pipeline Guide for CI/CD

This guide provides a complete step-by-step setup for a Jenkins pipeline that covers all your requirements for the Node.js dockerized project.

## 📋 Prerequisites

### 1. Jenkins Setup
- Jenkins server with Docker support
- Required Jenkins plugins:
  - Pipeline Plugin
  - Docker Pipeline Plugin
  - SonarQube Plugin
  - Git Plugin
  - Credentials Plugin

### 2. Required Tools on Jenkins Agent
- Docker & Docker Compose
- Git
- Node.js (for SonarQube scanner)
- SonarQube Scanner CLI

### 3. External Services
- SonarQube server (for code quality analysis)
- Docker registry (optional, for storing images)
- MongoDB production instance

## 🚀 Pipeline Stages Overview

The pipeline consists of the following stages:

1. **Pull Code from GitHub** - Checkout source code
2. **Build Docker Image** - Create containerized application
3. **Gitleaks Secret Scanning** - Scan for hardcoded secrets
4. **SonarQube Analysis** - Code quality and security analysis
5. **Quality Gate** - Wait for SonarQube quality gate
6. **Run Tests** - Unit and integration tests with DB
7. **DB Migration Approval** - Manual approval for production migration
8. **Run Database Migration** - Execute database changes
9. **Final Deployment Approval** - Manual approval for production deploy
10. **Deploy to Production** - Final deployment

## 📝 Step-by-Step Setup

### Step 1: Configure Jenkins Credentials

Create the following credentials in Jenkins (`Manage Jenkins` → `Manage Credentials`):

1. **GitHub Repository Access**
   ```
   Kind: Username with password / SSH Username with private key
   ID: github-credentials
   Description: GitHub Repository Access
   ```

2. **SonarQube Token**
   ```
   Kind: Secret text
   ID: sonarqube-token
   Secret: [Your SonarQube token]
   Description: SonarQube Analysis Token
   ```

3. **Production Database Connection**
   ```
   Kind: Secret text
   ID: prod-mongo-uri
   Secret: mongodb://[prod-server]:27017/production_db
   Description: Production MongoDB URI
   ```

### Step 2: Configure SonarQube Integration

1. **In Jenkins:**
   - Go to `Manage Jenkins` → `Configure System`
   - Find "SonarQube servers" section
   - Add SonarQube server:
     ```
     Name: SonarQube
     Server URL: http://your-sonarqube-server:9000
     Server authentication token: [Select your SonarQube token credential]
     ```

2. **In SonarQube:**
   - Create a new project with key: `nodejs-demo`
   - Generate authentication token
   - Configure quality gate rules as needed

### Step 3: Create Required Docker Compose Files

Create additional Docker Compose files for different environments:

#### docker-compose.test.yml (for testing)
```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - MONGO_URI=mongodb://mongo:27017/test_db
      - NODE_ENV=test
    depends_on:
      - mongo
  mongo:
    image: mongo:6.0
    restart: always
    environment:
      - MONGO_INITDB_DATABASE=test_db
    tmpfs:
      - /data/db
```

#### docker-compose.prod.yml (for production)
```yaml
services:
  app:
    image: nodejs-demo:latest
    ports:
      - "3000:3000"
    environment:
      - MONGO_URI=${PROD_MONGO_URI}
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Step 4: Create Jenkins Pipeline Job

1. **Create New Pipeline Job:**
   - Go to Jenkins dashboard
   - Click "New Item"
   - Enter name: `nodejs-demo-pipeline`
   - Select "Pipeline"
   - Click OK

2. **Configure Pipeline:**
   - In "Pipeline" section, select "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/Tusher-ajoy/cicd-demo.git`
   - Credentials: Select your GitHub credentials
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

3. **Configure Build Triggers:**
   - Check "GitHub hook trigger for GITScm polling"
   - Or set up periodic builds: `H/15 * * * *` (every 15 minutes)

### Step 5: Set Up GitHub Webhook (Optional)

1. Go to your GitHub repository settings
2. Navigate to "Webhooks"
3. Add webhook:
   ```
   Payload URL: http://your-jenkins-server/github-webhook/
   Content type: application/json
   Events: Just the push event
   ```

### Step 6: Environment Variables Configuration

Add these environment variables to your Jenkins job or system:

```bash
# In Jenkins job configuration or system environment
PROD_MONGO_URI=mongodb://production-server:27017/production_db
SONAR_HOST_URL=http://your-sonarqube-server:9000
DOCKER_REGISTRY=your-docker-registry.com  # Optional
```

## 🔧 Pipeline Features Explained

### 1. **GitHub Integration**
- Automatically pulls latest code
- Displays commit information
- Supports webhook triggers

### 2. **Docker Build**
- Builds optimized Docker image
- Tags with build number and latest
- Supports multi-stage builds

### 3. **Security Scanning**
- **Gitleaks**: Scans for hardcoded secrets and credentials
- Downloads and runs latest Gitleaks version
- Generates JSON report for review

### 4. **Code Quality Analysis**
- **SonarQube**: Comprehensive code analysis
- Runs tests with coverage first
- Enforces quality gate before proceeding

### 5. **Testing Strategy**
- **Parallel Testing**: Unit and integration tests run simultaneously
- **Database Testing**: Integration tests use real MongoDB
- **Test Isolation**: Each test run uses fresh database

### 6. **Manual Approvals**
- **DB Migration Approval**: Prevents accidental production changes
- **Deployment Approval**: Final safety check before production
- **Input Parameters**: Allows approval with notes

### 7. **Database Migration**
- Runs migration scripts safely
- Uses production database connection
- Provides rollback capability (implement as needed)

### 8. **Production Deployment**
- Health checks after deployment
- Rolling update capability
- Cleanup of old Docker images

## 🎯 Running the Pipeline

### Manual Trigger
1. Go to your Jenkins job
2. Click "Build Now"
3. Follow the console output
4. Approve manual steps when prompted

### Automatic Trigger
- Pipeline triggers automatically on code push (if webhook configured)
- Or runs on schedule if periodic builds are set

### Monitoring Progress
- Watch the Blue Ocean view for visual pipeline progress
- Check individual stage logs in console output
- Review test results and SonarQube reports

## 🚨 Troubleshooting Common Issues

### Docker Issues
```bash
# Check Docker daemon
sudo systemctl status docker

# Clean up Docker resources
docker system prune -a

# Check Docker permissions
sudo usermod -aG docker jenkins
```

### SonarQube Issues
```bash
# Check SonarQube connectivity
curl -u admin:admin http://sonarqube-server:9000/api/system/status

# Verify SonarQube scanner installation
sonar-scanner --version
```

### Database Connection Issues
```bash
# Test MongoDB connection
mongosh "mongodb://your-server:27017/test"

# Check network connectivity
telnet mongodb-server 27017
```

### Permission Issues
```bash
# Fix Jenkins workspace permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace/

# Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock
```

## 📊 Pipeline Reports and Artifacts

The pipeline generates several reports:

1. **Test Results**: JUnit XML format
2. **Coverage Reports**: LCOV format for SonarQube
3. **SonarQube Analysis**: Code quality metrics
4. **Gitleaks Report**: Security scan results
5. **Build Artifacts**: Docker images and logs

## 🔄 Pipeline Customization

### Adding New Stages
```groovy
stage('Custom Stage') {
    steps {
        echo 'Custom step execution'
        // Add your custom logic here
    }
}
```

### Environment-Specific Configurations
```groovy
script {
    if (env.BRANCH_NAME == 'main') {
        // Production-specific logic
    } else if (env.BRANCH_NAME == 'develop') {
        // Development-specific logic
    }
}
```

### Notification Integration
```groovy
post {
    success {
        slackSend(
            channel: '#deployments',
            message: "✅ Deployment successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

## 🎉 Conclusion

This Jenkins pipeline provides a robust CI/CD solution that:
- ✅ Ensures code quality through automated analysis
- ✅ Maintains security through secret scanning
- ✅ Provides safety through manual approvals
- ✅ Supports rollback and monitoring
- ✅ Follows DevOps best practices

The pipeline is designed to be maintainable, scalable, and secure for production use.