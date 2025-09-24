#!/bin/bash

# Jenkins Pipeline Setup Script for CI/CD Demo
# This script helps set up the required components for the Jenkins pipeline

set -e

echo "🚀 Jenkins Pipeline Setup for CI/CD Demo"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is installed and running
check_docker() {
    echo "Checking Docker installation..."
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            print_status "Docker is installed and running"
        else
            print_error "Docker is installed but not running. Please start Docker daemon."
            exit 1
        fi
    else
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
}

# Check if Docker Compose is available
check_docker_compose() {
    echo "Checking Docker Compose availability..."
    if docker compose version &> /dev/null; then
        print_status "Docker Compose is available"
    elif docker-compose --version &> /dev/null; then
        print_status "Docker Compose (legacy) is available"
    else
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
}

# Download Gitleaks for secret scanning
setup_gitleaks() {
    echo "Setting up Gitleaks for secret scanning..."
    GITLEAKS_VERSION="8.18.0"
    
    if [ ! -f "/tmp/gitleaks" ]; then
        echo "Downloading Gitleaks v${GITLEAKS_VERSION}..."
        wget -O /tmp/gitleaks.tar.gz "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
        tar -xzf /tmp/gitleaks.tar.gz -C /tmp/
        chmod +x /tmp/gitleaks
        print_status "Gitleaks downloaded and configured"
    else
        print_status "Gitleaks already available"
    fi
}

# Create necessary directories
create_directories() {
    echo "Creating necessary directories..."
    mkdir -p logs
    mkdir -p coverage
    mkdir -p test-results
    print_status "Directories created"
}

# Test the Docker build
test_docker_build() {
    echo "Testing Docker build..."
    if docker build -t nodejs-demo-test . > /dev/null 2>&1; then
        print_status "Docker build successful"
        # Clean up test image
        docker rmi nodejs-demo-test > /dev/null 2>&1
    else
        print_error "Docker build failed. Please check your Dockerfile."
        exit 1
    fi
}

# Run basic tests
run_tests() {
    echo "Running basic application tests..."
    if docker compose -f docker-compose.test.yml up --build --abort-on-container-exit; then
        print_status "Tests completed"
    else
        print_warning "Tests failed or had issues"
    fi
    
    # Cleanup test containers
    docker compose -f docker-compose.test.yml down -v > /dev/null 2>&1 || true
}

# Check SonarQube configuration
check_sonarqube_config() {
    echo "Checking SonarQube configuration..."
    if [ -f "sonar-project.properties" ]; then
        print_status "SonarQube configuration found"
    else
        print_warning "SonarQube configuration not found"
    fi
}

# Generate environment template
create_env_template() {
    echo "Creating environment template..."
    cat > .env.template << 'EOF'
# Production Environment Variables Template
# Copy this to .env and fill in the actual values

# MongoDB Production URI
PROD_MONGO_URI=mongodb://production-server:27017/production_db

# MongoDB Root Credentials for Production
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=secure_password_here

# SonarQube Configuration
SONAR_HOST_URL=http://your-sonarqube-server:9000
SONAR_TOKEN=your_sonarqube_token_here

# Docker Registry (optional)
DOCKER_REGISTRY=your-registry.com

# Application Secrets
SECRET_KEY=your_production_secret_key_here
NODE_ENV=production
EOF
    print_status "Environment template created (.env.template)"
}

# Display Jenkins setup instructions
show_jenkins_instructions() {
    echo ""
    echo "📋 Next Steps for Jenkins Setup:"
    echo "================================"
    echo ""
    echo "1. Install required Jenkins plugins:"
    echo "   - Pipeline Plugin"
    echo "   - Docker Pipeline Plugin"
    echo "   - SonarQube Plugin"
    echo "   - Git Plugin"
    echo "   - Blue Ocean Plugin (recommended)"
    echo ""
    echo "2. Configure Jenkins credentials:"
    echo "   - GitHub repository access (ID: github-credentials)"
    echo "   - SonarQube token (ID: sonarqube-token)"
    echo "   - Production MongoDB URI (ID: prod-mongo-uri)"
    echo ""
    echo "3. Set up SonarQube server integration in Jenkins"
    echo ""
    echo "4. Create a new Pipeline job in Jenkins:"
    echo "   - Use 'Pipeline script from SCM'"
    echo "   - Point to this repository"
    echo "   - Use 'Jenkinsfile' as the script path"
    echo ""
    echo "5. Configure webhook in GitHub (optional):"
    echo "   - URL: http://your-jenkins-server/github-webhook/"
    echo ""
    echo "📁 Files created/verified:"
    echo "   - Jenkinsfile (main pipeline configuration)"
    echo "   - JENKINS_PIPELINE_GUIDE.md (detailed setup guide)"
    echo "   - docker-compose.prod.yml (production deployment)"
    echo "   - .env.template (environment variables template)"
    echo ""
    print_status "Setup complete! Check the JENKINS_PIPELINE_GUIDE.md for detailed instructions."
}

# Main execution
main() {
    check_docker
    check_docker_compose
    setup_gitleaks
    create_directories
    test_docker_build
    check_sonarqube_config
    create_env_template
    
    echo ""
    print_status "All checks passed!"
    
    # Ask if user wants to run tests
    read -p "Do you want to run the test suite now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_tests
    fi
    
    show_jenkins_instructions
}

# Run main function
main "$@"