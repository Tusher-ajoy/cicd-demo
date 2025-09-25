# 🚀 Simple Jenkins Pipeline Setup Guide

## 📋 What This Pipeline Does

This is a **self-contained Jenkins pipeline** that covers all your CI/CD requirements without external configurations:

### Pipeline Stages:
1. **🔄 Checkout Code** - Pulls code directly from GitHub
2. **🐳 Docker Build** - Builds with `docker compose build`
3. **🔍 Secret Scanning** - Gitleaks security scan
4. **🧪 Tests** - Unit & integration tests with database
5. **📊 SonarQube Analysis** - Code quality analysis (simulated)
6. **⏸️ DB Migration Approval** - Manual approval required
7. **🗃️ Database Migration** - Runs database migrations
8. **⏸️ Final Deployment Approval** - Manual approval required
9. **🚀 Deploy** - Deploys with `docker compose up -d`
10. **🔍 Verify Containers** - Shows running containers

## 🎯 Simple Jenkins Setup

### Step 1: Create Pipeline Job

1. **Go to Jenkins:** http://localhost:9090
2. **Click "New Item"**
3. **Name:** `cicd-demo-simple-pipeline`
4. **Type:** Pipeline
5. **Click OK**

### Step 2: Configure Pipeline

In the pipeline configuration:

1. **Pipeline Section:**
   - Definition: **"Pipeline script"** (not from SCM!)
   - Script: **Copy and paste the entire Jenkinsfile content**

2. **Save the job**

### Step 3: Run the Pipeline

1. **Click "Build Now"**
2. **Monitor the stages** in real-time
3. **Approve manual steps** when prompted

## 🎮 How to Use Manual Approvals

### During DB Migration Approval:
- Pipeline will pause at stage 6
- Click the **blue "Input Required"** button
- Select **"Yes"** to approve migration
- Pipeline continues automatically

### During Final Deployment Approval:
- Pipeline will pause at stage 8
- Click the **blue "Input Required"** button  
- Select **"Yes"** to approve deployment
- Add optional deployment notes
- Pipeline continues to deploy

## 📊 What You'll See

### Expected Output:
```
🔄 Checkout Code from GitHub ✅
🐳 Docker Build ✅
🔍 Gitleaks Secret Scanning ⚠️ (finds test secret - normal)
🧪 Run Unit & Integration Tests ✅
📊 SonarQube Code Analysis ✅
⏸️ Database Migration Approval (MANUAL - Click Yes)
🗃️ Database Migration ✅
⏸️ Final Deployment Approval (MANUAL - Click Yes)
🚀 Deploy with Docker Compose ✅
🔍 Check Running Containers ✅
```

### Success Message:
```
✅ DEPLOYMENT SUCCESSFUL! 
📝 Summary:
   • Application: nodejs-demo
   • Commit: abc123f
   • Build: 123
   • Status: Successfully deployed and running
   • Containers: Use 'docker compose ps' to check status
```

## 🔧 Pipeline Features

### ✅ **No External Configuration Needed:**
- Git checkout is built into the pipeline
- No SCM configuration required
- No credentials setup needed (for public repos)
- All commands use Docker Compose

### ✅ **Complete CI/CD Workflow:**
- Code checkout from GitHub
- Docker containerization
- Security scanning (Gitleaks)
- Automated testing with database
- Code quality analysis
- Manual approval gates
- Production deployment
- Container verification

### ✅ **Easy Monitoring:**
- Clear stage names with emojis
- Detailed logging in each step
- Manual approval notifications
- Success/failure notifications
- Automatic rollback on failure

## 🚨 Troubleshooting

### If Pipeline Fails:

1. **Check Console Output** for detailed error messages
2. **Common Issues:**
   - Docker daemon not running: `sudo systemctl start docker`
   - Port 27017 in use: `sudo lsof -i :27017` (stop MongoDB if running)
   - Permission issues: `sudo usermod -aG docker $USER`

### If Manual Approval Doesn't Show:
1. Refresh Jenkins page
2. Look for blue "Input Required" button
3. Check Console Output for approval links
4. Click directly on the paused stage

## 🎊 Next Steps

### After Successful Run:
1. **Check your application:** 
   ```bash
   docker compose ps
   curl http://localhost:3000  # If your app runs on port 3000
   ```

2. **View container logs:**
   ```bash
   docker compose logs app
   docker compose logs mongo
   ```

3. **Stop the application:**
   ```bash
   docker compose down
   ```

### For Production Use:
1. Add real SonarQube integration
2. Configure actual production deployment
3. Set up GitHub webhooks for automatic triggers
4. Add notification integrations (Slack, email)
5. Configure proper secret management

---

**This pipeline is ready to run immediately without any additional setup!** 🚀

Just copy the Jenkinsfile content into a new Jenkins Pipeline job and click "Build Now".