pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "nodejs-demo"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('🔄 Pull Code from GitHub') {
            steps {
                echo '🚀 Pulling latest code from GitHub...'
                checkout scm
                
                script {
                    def commitId = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    def commitMessage = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                    echo "📝 Building commit: ${commitId}"
                    echo "💬 Commit message: ${commitMessage}"
                    
                    // Store commit info for later use
                    env.COMMIT_ID = commitId
                    env.COMMIT_MESSAGE = commitMessage
                }
            }
        }
        
        stage('🐳 Build Docker Image') {
            steps {
                echo '🔨 Building Docker image...'
                script {
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    // Also tag as latest
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    echo "✅ Docker image built successfully: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('🔍 Gitleaks Secret Scanning') {
            steps {
                echo '🔒 Running Gitleaks for secret scanning...'
                script {
                    // Use the Gitleaks binary we downloaded
                    def gitleaksResult = sh(returnStatus: true, script: '''
                        if [ ! -f /tmp/gitleaks ]; then
                            echo "Gitleaks not found, downloading..."
                            wget -O /tmp/gitleaks.tar.gz https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks_8.18.0_linux_x64.tar.gz
                            tar -xzf /tmp/gitleaks.tar.gz -C /tmp/
                            chmod +x /tmp/gitleaks
                        fi
                        
                        echo "Running Gitleaks scan..."
                        /tmp/gitleaks detect --source . --report-format json --report-path gitleaks-report.json --verbose
                    ''')
                    
                    if (gitleaksResult != 0) {
                        echo '⚠️ Secrets detected by Gitleaks!'
                        archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                        unstable(message: "Gitleaks detected potential secrets")
                    } else {
                        echo '✅ No secrets detected by Gitleaks'
                    }
                }
            }
        }
        
        stage('🧪 Run Unit Tests') {
            steps {
                echo '🧪 Running unit tests...'
                script {
                    sh '''
                        echo "Running tests in Docker container..."
                        docker run --rm -v $(pwd):/app -w /app node:20-alpine sh -c "
                            npm install --omit=dev &&
                            npm install --save-dev jest supertest &&
                            npm test
                        "
                    '''
                    echo '✅ Unit tests completed successfully!'
                }
            }
            post {
                always {
                    echo '📊 Archiving test results...'
                }
            }
        }
        
        stage('📊 Code Quality Check') {
            steps {
                echo '📊 Running basic code quality checks...'
                script {
                    // Basic file structure validation
                    sh '''
                        echo "Checking project structure..."
                        ls -la
                        echo "Checking package.json..."
                        cat package.json
                        echo "Checking Dockerfile..."
                        cat Dockerfile
                    '''
                    echo '✅ Code quality checks completed!'
                }
            }
        }
        
        stage('⏸️ Database Migration Approval') {
            steps {
                script {
                    echo '⏳ Database migration requires manual approval...'
                    def userInput = input(
                        id: 'dbMigrationApproval',
                        message: '🔄 Approve database migration to production?',
                        parameters: [
                            choice(
                                name: 'APPROVE_MIGRATION',
                                choices: ['No', 'Yes'],
                                description: 'Do you approve running database migrations in production?'
                            )
                        ]
                    )
                    
                    if (userInput != 'Yes') {
                        error('❌ Database migration was not approved')
                    }
                    
                    echo '✅ Database migration approved!'
                }
            }
        }
        
        stage('🗃️ Run Database Migration') {
            steps {
                echo '🗃️ Running database migration...'
                script {
                    // Simulate database migration
                    echo '📝 Simulating database migration...'
                    sh '''
                        echo "Running migration script..."
                        docker run --rm -v $(pwd):/app -w /app ${DOCKER_IMAGE}:${DOCKER_TAG} sh -c "
                            echo 'Database migration simulation completed'
                            echo 'In production, this would run: npm run migrate'
                        "
                    '''
                    echo '✅ Database migration completed successfully!'
                }
            }
        }
        
        stage('⏸️ Final Deployment Approval') {
            steps {
                script {
                    echo '⏳ Final deployment requires manual approval...'
                    def deployInput = input(
                        id: 'deploymentApproval',
                        message: '🚀 Approve final deployment to production?',
                        parameters: [
                            choice(
                                name: 'APPROVE_DEPLOY',
                                choices: ['No', 'Yes'],
                                description: 'Do you approve deploying to production?'
                            ),
                            string(
                                name: 'DEPLOYMENT_NOTES',
                                defaultValue: '',
                                description: 'Optional deployment notes'
                            )
                        ]
                    )
                    
                    if (deployInput.APPROVE_DEPLOY != 'Yes') {
                        error('❌ Final deployment was not approved')
                    }
                    
                    echo "✅ Final deployment approved!"
                    if (deployInput.DEPLOYMENT_NOTES) {
                        echo "📝 Deployment notes: ${deployInput.DEPLOYMENT_NOTES}"
                    }
                }
            }
        }
        
        stage('🚀 Deploy to Production') {
            steps {
                echo '🚀 Deploying to production...'
                script {
                    // Tag image for production
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:production"
                    
                    echo '🏷️ Tagged image for production'
                    echo '🎯 Simulating production deployment...'
                    
                    // Simulate deployment
                    sh '''
                        echo "Production deployment simulation:"
                        echo "- Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        echo "- Commit: ${COMMIT_ID}"
                        echo "- Build: ${BUILD_NUMBER}"
                        echo "- Timestamp: $(date)"
                        
                        # In real scenario, this would deploy to your production environment
                        echo "Deployment completed successfully!"
                    '''
                    
                    echo '✅ Production deployment completed successfully!'
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up workspace...'
            // Clean up old Docker images (keep last 3 builds)
            sh '''
                echo "Cleaning up old Docker images..."
                docker images ${DOCKER_IMAGE} --format "table {{.Tag}}" | grep -E "^[0-9]+$" | sort -n | head -n -3 | xargs -r -I {} docker rmi ${DOCKER_IMAGE}:{} || true
            '''
        }
        
        success {
            echo '🎉 Pipeline completed successfully!'
            
            script {
                echo """
                ✅ DEPLOYMENT SUCCESSFUL! 
                📝 Summary:
                   • Commit: ${env.COMMIT_ID}
                   • Build: ${env.BUILD_NUMBER} 
                   • Image: ${DOCKER_IMAGE}:${DOCKER_TAG}
                   • Status: Successfully deployed to production
                """
            }
        }
        
        failure {
            echo '❌ Pipeline failed!'
            echo "💥 Failed at stage: ${env.STAGE_NAME}"
            
            // Archive any logs for troubleshooting
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
        }
        
        unstable {
            echo '⚠️ Pipeline completed with warnings!'
        }
    }
}